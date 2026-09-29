## Context

mxcat-commit 在 Windows PowerShell 上用子进程创建提交：父会话把说明管道给 `powershell -NoProfile -File commit_one.ps1`。子进程让脚本里的 `exit` 只结束自己，并把退出码交回调用方。

当前机器是 Windows PowerShell 5.1。`$OutputEncoding` 默认是 US-ASCII，控制台代码页是 gb2312。父会话按 ASCII 写出管道时，非 ASCII 字符变成 `?`。脚本先枚举 `$input`，这些问号已经是字符串，后面的 UTF-8 标准输入分支不会执行。

同一子进程里，Git 以 UTF-8 打印仓库根。PowerShell 按 gb2312 解码后，`杂` 变成 `鏉?`。`git -C` 因此失败。`Get-StagedRenameNew` 把失败当成「没有改名」，`ls-files` / `ls-tree` 的失败也没有中止脚本。随后不带 `-C` 的 `git add` 与 `git commit` 仍用当前目录成功，于是文件被提交，说明却是问号。本地 `a0e0954` 就是这个结果，且尚未推送。

## Goals / Non-Goals

**Goals:**

- 父会话以无 BOM 的 UTF-8 送出说明时，子进程提交到 Git 的说明与原文一致，包括中文
- 仓库根路径含非 ASCII 字符时，`git -C` 使用解码后的真实路径
- `git -C` 失败时在 `git commit` 之前以非零退出，不创建 commit
- sh/bash/zsh 的 `scripts/commit_one` 调用方式保持不变

**Non-Goals:**

- 不自动 `reset` 或改写已经作成的 `a0e0954`
- 不在说明已被父会话替换成 `?` 之后猜测原文
- 不把提交入口改成当前进程里的 `& commit_one.ps1`（见 Decisions）
- 不改变标题骨架、预览门禁或 POSIX 入口

## Decisions

### 1. 继续使用子进程 `powershell -NoProfile -File`

在 Windows PowerShell 5.1 里，用 `&` 调用脚本时，脚本中的 `exit` 会结束当前会话。子进程把退出码限制在入口自己身上，调用方会话还在。

同一进程调用虽然能让 `$input` 直接成为 .NET 字符串，但换掉现有入口的进程模型。编码问题可以在子进程边界上修好，不必承担这个副作用。

### 2. 重定向的标准输入按原始 UTF-8 字节读取，不使用 `$input`

`powershell -File` 在脚本运行前不会把标准输入收成 Unicode。一旦脚本枚举 `$input`，宿主会按当时的控制台代码页解码，gb2312 会把父会话送来的 UTF-8 再解错一次。

标准输入被重定向时，入口用无 BOM 的 UTF-8 读完原始字节。入口脚本里不能出现自动变量 `input` 的标记：Windows PowerShell 5.1 会因此在脚本运行前用控制台代码页把标准输入收走，原始字节变为空，事后再改 `[Console]::InputEncoding` 也来不及。没有重定向时，用 `Get-Variable -Name input` 读取同一进程管道里的字符串。控制台输出编码要在读完说明之后、第一次调用 Git 之前再设置；读之前就改 `[Console]::OutputEncoding` 也会把尚未读取的标准输入清掉。

父会话必须在同一段命令里把 `$OutputEncoding` 设为无 BOM 的 UTF-8，再管道给子进程。只改脚本、父会话仍用 US-ASCII 时，字节里已经是 `?`，入口无从恢复。因此 batch 与 single 的 PowerShell 示例都要带上这个赋值。

### 3. 在第一次调用 Git 之前把子进程控制台编码设为 UTF-8

只影响子进程。`[Console]::OutputEncoding` 与 `$OutputEncoding` 都设为无 BOM UTF-8，使 `git rev-parse --show-toplevel` 的输出按 UTF-8 进入 .NET 字符串。Git for Windows 在这条路径上打印的是 UTF-8（`杂` 的字节被 gb2312 误读才会变成 `鏉?`）。

不在父会话里改代码页。子进程结束即丢弃这些设置。

### 4. `git -C` 失败即停止

解析出仓库根之后，用该根执行 `git -C` 探测；失败则在添加索引和 `git commit` 之前退出。已经存在的 `git -C` 调用（含改名检测、`ls-files`、`ls-tree`）在非零退出时同样停止，不再把空输出当成「没有暂存信息」。

不带 `-C` 的 `git add` / `git commit` 只在上述检查都成功之后运行。

## Risks / Trade-offs

- [父会话忘记设置 `$OutputEncoding`] → 说明仍会变成问号。文档示例把赋值和管道写在同一段命令里；脚本无法区分「用户真的写了问号」和「ASCII 替换」。
- [Git 某次不以 UTF-8 打印路径] → 强行按 UTF-8 解码会得到另一串错误路径，随后 `git -C` 探测失败并停止，避免再把文件提交进去。
- [标准输入重定向但内容不是 UTF-8] → 说明会按 UTF-8 解码失败或变成替换字符。约定的调用方只送 UTF-8，不接受系统代码页字节。
- [子进程多一次启动] → 保留现有进程模型，换取退出码隔离。提交不是热路径。

## Migration Plan

1. 更新 `commit_one.ps1` 的编码与失败处理。
2. 更新 `batch-commit.md` 与 `single-commit.md` 的 PowerShell 示例，在管道前设置 `$OutputEncoding`。
3. 回滚时还原上述文件即可。没有数据迁移。
4. `a0e0954` 留在本地，直到使用方明确要求撤回再按新入口重提。本变更不执行 `git reset` 或 `git push`。

## Open Questions

无。调用边界和失败策略按上面四条决定执行。
