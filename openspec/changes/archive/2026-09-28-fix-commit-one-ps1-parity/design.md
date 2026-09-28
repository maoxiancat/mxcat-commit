## Context

见 `proposal.md` 的 Why。shell 版 `commit_one` 用 `cat` 按字节收下标准输入。`commit_one.ps1` 与 `validate.ps1` 先枚举 `$input`，只有它为空才设置 `[Console]::InputEncoding` 再读 `[Console]::In`。Windows PowerShell 5.1 的默认 `$OutputEncoding` 是 ASCII；中文 Windows 上控制台输入编码是 OEM 代码页（GBK）。`[Console]::In` 在宿主启动时已经按该代码页建好，事后改 `InputEncoding` 不会换掉这个 reader。

换入循环里，补丁按行切开的写法把 `` -split "`n", -1 `` 解析成「用一个二元数组当分隔符」。可执行位只在 `core.filemode` 不是 `true` 时写 index，复制出的文件本身没有 `chmod`。符号链接用 `New-Item -LiteralPath` 创建，PowerShell 7 的 `New-Item` 没有这个参数，失败后的恢复走同一条命令。Windows 路径分支用 `GetFullPath`，不解析目录符号链接。

## Goals / Non-Goals

**Goals:**

- 文档中的 PowerShell 调用把生成的说明原样送进 commit；父进程送出的 UTF-8 字节按 UTF-8 读入。
- `commit_one.ps1` 的 `--hunks`、可执行位、符号链接恢复、Windows 目录符号链接与 shell 版同一结果。
- 两份 PowerShell 入口共用同一种读法。

**Non-Goals:**

- 不删除脚本，不把这些检查改成生成时的自检清单。
- 不根据问号或「澧炲姞」反推原文。误读一旦变成替换字符，原文已经不在。
- 不改 shell 版 `commit_one` / `validate` 的检查规则，不改预览门禁和消息骨架。
- 不重写已经写坏的历史 commit。

## Decisions

### Decision: 跨进程标准输入按 UTF-8 字节读，同进程管道仍用 `$input`

重定向的标准输入用 `OpenStandardInput()` 配无 BOM 的 UTF-8 `StreamReader` 读完，并且发生在任何 `$input` 枚举之前。没有重定向时，`$input` 里的 .NET 字符串原样使用（同进程 here-string 不经过代码页）。不再设置 `[Console]::InputEncoding` 后去读 `[Console]::In`。

`Read-CommitMessage` 放在 `validate.ps1`。`commit_one.ps1` 点源之后调用它；`validate.ps1` 作为脚本执行时也调用它。点源路径仍然只做 `Test-CommitMessage`，不再读一次标准输入。

Alternatives considered:

- 只改 guide、脚本继续用 `$input`：父进程若已是 UTF-8，子进程 5.1 仍按 GBK 读，「增加」仍会变成「澧炲姞」。
- 读到乱码再按 GBK 回合：只对可逆的误读有效，问号回不来，合法的非中文文本也可能被误伤。
- 检测 header 合格但「看起来像乱码」就拒绝：没有稳定判据，会挡住正常说明。

### Decision: guide 在管道之前把父进程输出编码设为 UTF-8

`single-commit.md` 与 `batch-commit.md` 的 PowerShell 示例保持 `powershell -NoProfile -File`（继续绕过执行策略），在管道之前先执行：

```powershell
$OutputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
```

这挡住 5.1 默认 ASCII 把非 ASCII 换成问号。子进程的 UTF-8 读取挡住 GBK 误读。两边都要，缺一边仍会坏。

若在 Windows PowerShell 5.1 上核实到 `-File` 的宿主在脚本开头之前已经用 OEM 代码页把标准输入读进 `$input`、原始字节已经不在，guide 改为在同一个子进程里写 here-string 再管道给脚本（消息以 .NET 字符串进入 `$input`），不再把消息字节交给第二个进程解码。实现时先核实，再决定是否改成这一种；规格里的结果不变。

Alternatives considered:

- 一律改成同进程 `& .\commit_one.ps1`：执行策略会挡住 `-File` 今天能跑的环境。
- 只在子进程里改编码：问号在父进程管道里已经产生，子进程看不到原来的字。

### Decision: 补丁按换行切开，不用带逗号的 `-split`

`Get-PatchPaths` 与 `Get-HunkTexts` 改为按换行拆开并保留空段，例如 `` -split "`n" `` 或按字符 `` `n `` 的 `Split`。逗号在 `-split` 的「最大段数」之前结合，`` -split "`n", -1 `` 不会按行切开。行尾 `\r` 仍去掉。现有 hunk 子集规则不变。

### Decision: 换入时的模式与 shell 版同一顺序

复制出 blob 之后：`100755` 置可执行位，其它普通文件清掉可执行位。文件系统表达不了该位时（`core.filemode` 不是 `true`，或文件仍不可执行），再 `git update-index --chmod=+x`。`core.filemode=true` 时不得只靠「跳过 update-index」就提交 `100644`。

符号链接的创建和失败后的恢复共用一个不带 `-LiteralPath` 的调用（`New-Item -ItemType SymbolicLink -Path -Target`）。`New-Item` 在 PowerShell 7 上没有 `-LiteralPath`，创建和 `finally` 里的恢复会一起失败，原链接已经删掉。

`git cat-file blob` 的字节原样写入临时文件，再按模式落到工作区。不用 `Start-Process -RedirectStandardOutput` 的文本重定向，避免换入时把 blob 按系统 ANSI 重编码。

### Decision: Windows 分支取目录的最终路径

`Resolve-PhysicalDirectory` 在 Windows 上用目录句柄的最终路径（`GetFinalPathNameByHandle` 或等价结果），去掉 `\\?\` 前缀后再和仓库根比较。`GetFullPath` 不解析符号链接，所以经链接进入仓库的绝对路径会被判成仓库外。非 Windows 分支继续 `cd -P`。

## Risks / Trade-offs

- [Risk] 示例里设置 `$OutputEncoding` 会留在当前 PowerShell 会话，后面的本机程序输出也按 UTF-8 解码。  
  Mitigation: 这是中文说明要保留时父进程应有的编码；不把会话改回 ASCII。

- [Risk] 5.1 的 `-File` 在脚本运行前已经解码标准输入，原始字节读不到。  
  Mitigation: 见上，核实后把 guide 改成同一子进程内的 here-string。规格只要求 commit 里的说明等于生成的文字。

- [Risk] 路径里含 `*?[]` 时，`New-Item -Path` 会把它们当通配符。  
  Mitigation: 这种路径先取字面量形式再创建链接；创建失败仍走恢复，不得留下已删除的原路径。

- [Risk] 已经提交的乱码说明不会被这次修改改写。  
  Mitigation: 只影响新的 `commit_one.ps1` 调用。用户若要改历史，仍按现有约定等明确要求后再 reset。

## Migration Plan

1. 改两份 PowerShell 脚本的读入、换行拆分、换入模式和 Windows 路径解析。
2. 改两份 guide 的 PowerShell 示例。
3. 在 `CHANGELOG.md` 顶部按现有条目格式记一笔。
4. 回滚即还原上述文件。不迁移已有 commit。
