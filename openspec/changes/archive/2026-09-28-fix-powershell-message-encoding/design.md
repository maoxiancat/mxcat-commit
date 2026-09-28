## Context

见 `proposal.md` 的 Why。文档现在的 PowerShell 示例在管道之前设置 `$OutputEncoding`，再把含中文的 here-string 管道给第二个 `powershell -NoProfile -File`。`Read-CommitMessage` 在标准输入被重定向时先按无 BOM 的 UTF-8 读完字节，读到空才使用 `$input`。Windows PowerShell 5.1 把没有 BOM 的命令文本按系统 ANSI 代码页解析；简体中文 Windows 上该代码页与 OEM 代码页都是 936。

## Goals / Non-Goals

**Goals:**

- 文档中的调用在 5.1 按代码页 936 解析命令文本时，送进 commit 的说明仍是生成的原文。
- 同一次进程内的管道对象优先于进程标准输入上的其它字节。管道为空时，重定向的标准输入仍按 UTF-8 字节读取。
- 入口返回 0 之后，用 ASCII 十六进制码点对照生成的文字。

**Non-Goals:**

- 不根据问号或「澧炲姞」反推原文。
- 不改 shell 版 `commit_one` / `validate` 的读法和自检。
- 不改预览门禁、消息骨架、可执行位、符号链接和路径解析。
- 不重写已经写坏的历史 commit。
- 不把仓库路径也改成 Base64。

## Decisions

### Decision: 说明以 UTF-8 的 Base64 进入命令，在同一进程内解码后再管道

`single-commit.md` 与 `batch-commit.md` 的 PowerShell 示例改为同一次调用里的三条语句。整段说明（含 header 与正文）先变成 UTF-8 的 Base64，命令正文只有 ASCII。进程内解码成一个 .NET 字符串，再管道给 `scripts/commit_one.ps1`。执行策略用 `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force` 放行这一次进程，不再套第二个 `powershell -File`。删掉管道前的 `$OutputEncoding` 赋值。

ASCII 在 UTF-8 与代码页 936 中是同一批字节，所以 5.1 解析命令文本时解不出「澧炲姞」。中文在解码之后才出现，随后管道传递的是对象。

示例保持「增加空数据占位」那段说明，Base64 覆盖整段，包含标题与正文之间的空行。batch 的每条 commit 各自编码、各自管道。

Alternatives considered:

- 只改成同进程明文 here-string：5.1 解析命令文本时，here-string 里的「增加」已经是「澧炲姞」，管道会原样提交。
- 继续跨进程并只设 `$OutputEncoding`：挡不住命令文本这一层；5.1 若在脚本开头之前按 GBK 读管道，子进程的 UTF-8 读取拿到空，退回的仍是错字。
- 在脚本里把错字按 GBK 转回：问号回不来，合法正文也可能被误伤。

### Decision: 管道里已有字符串就用它，否则再读 UTF-8 字节

`Read-CommitMessage` 先看调用方传入的管道。其中已有字符串时直接使用：一项原样返回，多于一项时仍用换行接上并在末尾补一个换行。管道为空且标准输入被重定向时，再用 `OpenStandardInput()` 和无 BOM 的 UTF-8 `StreamReader` 读完。不设置 `[Console]::InputEncoding`，也不读 `[Console]::In`。

`commit_one.ps1` 继续点源 `validate.ps1` 后调用该函数。点源路径仍然只做 `Test-CommitMessage`。

同进程管道在 PowerShell 7 上会把 `[Console]::IsInputRedirected` 报成 true，标准输入却是空的。先看管道，进程标准输入里的其它字节不会把说明抢走。管道为空时的 UTF-8 读取留下：父进程字节还在、管道没有字符串时，「增加」仍按 UTF-8 进入。

Alternatives considered:

- 维持先读标准输入：同进程调用时，标准输入里若还有其它字节，合格说明会被丢掉。
- 任何情况下都先枚举 `$input`：在仍使用 `powershell -File` 的旧调用上，5.1 可能因此按代码页 936 把标准输入收进管道，UTF-8 字节不再被读到。文档不再使用那种调用；管道为空时的 UTF-8 读取仍留给字节还在、管道确实为空的调用。

### Decision: 成功后在同一进程里打码点，由技能对照预览

入口返回 0 之后，同一进程把 `[Console]::OutputEncoding` 设为无 BOM 的 UTF-8，用 `git -c i18n.logOutputEncoding=utf-8 log -1 --format=%B` 取出说明，再把每个码点打成四位十六进制。两侧各去掉末尾一个换行后对照。指南写明「增加」是 `589E 52A0`，「澧炲姞」是 `6FA7 70B2 59DE`。不一致则停止，不写成功回执，不 amend。shell 的第 6 步不增加这一段。

十六进制是 ASCII，代码页 936 的屏幕不能把对照结论再写成错字。脚本不保存「预览里原来那句」，所以对照放在指南里，由生成说明的一方完成。

Alternatives considered:

- 只比较 `$msg` 与 commit 说明：Base64 编错时两边一起错，对照仍通过。
- 让脚本拒绝「看起来像乱码」的说明：没有稳定判据。

## Risks / Trade-offs

- [Risk] Base64 编错但解码结果仍是合格 header 时，入口会创建 commit。  
  Mitigation: 码点对照的是预览里生成的那句，不一致就停，不 amend。

- [Risk] 组策略禁止 `Set-ExecutionPolicy` 时，同进程调用 `.ps1` 会被执行策略挡住。  
  Mitigation: 指南仍用进程范围的 Bypass。挡下时报告策略错误并停止，不改回跨进程 `-File`。

- [Risk] 路径参数含非 ASCII 时，5.1 仍会按代码页 936 解析这些参数。  
  Mitigation: 本变更只编码说明。路径继续用预览里的仓库相对路径。

- [Risk] 旧的「明文 here-string 管道给 `powershell -File`」在管道被 5.1 预先解码时仍会写坏。  
  Mitigation: 两份 guide 改为新调用。管道为空时的 UTF-8 读取保留给字节还在的调用。

- [Risk] 进程范围的执行策略和输出编码会留在当前 PowerShell 会话。  
  Mitigation: 二者都只服务这一次提交。不在指南里把编码改回代码页 936。

- [Risk] 已经提交的错字不会被这次修改改写。  
  Mitigation: 只影响新的调用。改历史仍须另有明确要求。

## Migration Plan

1. 改 `validate.ps1` 的读入顺序。`commit_one.ps1` 继续调用它。
2. 改两份 guide 的 PowerShell 示例，并在 PowerShell 的提交后自检中加上码点对照。
3. 在 `CHANGELOG.md` 顶部按现有条目格式记一笔。
4. 回滚即还原上述文件。不迁移已有 commit。
