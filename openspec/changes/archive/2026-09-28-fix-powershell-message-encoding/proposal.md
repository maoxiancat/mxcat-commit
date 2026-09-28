## Why

Windows PowerShell 5.1 上按 guide 提交时，简体中文说明会在进 `commit_one.ps1` 之前被写成错字：无 BOM 的命令文本按代码页 936 解析，或父进程把 UTF-8 管道给第二个 `powershell -File` 再按 GBK 读入，「增加」都会变成「澧炲姞」。header 仍是 ASCII，校验放行，commit 已经留下。1.4.5 只在标准输入上还留着原始字节时按 UTF-8 读取，挡不住命令文本本身已被按 GBK 解析的那一层。

## What Changes

- 文档中的 Windows PowerShell 调用改为同一次进程：说明以 UTF-8 的 Base64 写在只含 ASCII 的命令里，进进程后解成 .NET 字符串，再管道给 `commit_one.ps1`。不再把含中文的明文管道给第二个 `powershell -File`，也不再依赖管道前设置 `$OutputEncoding`。
- 管道里已经有字符串时，`commit_one.ps1` 与单独运行的 `validate.ps1` 使用这份字符串。管道为空且标准输入被重定向时，仍按无 BOM 的 UTF-8 读原始字节。
- 入口返回 0 之后，用新建 commit 说明的 Unicode 码点对照本次生成的文字。码点以 ASCII 十六进制取出，代码页 936 的屏幕不能改写对照结论。不一致则停止，不写成功回执，也不 amend。
- 不根据「澧炲姞」或问号反推原文。不改 shell 版入口，不改预览门禁和消息骨架。

## Capabilities

### New Capabilities

### Modified Capabilities

- `mxcat-commit-workflow`: 文档中的 PowerShell 调用必须在命令文本只含 ASCII 的同一次进程里把说明原样送进 commit；提交成功后必须用码点对照生成的文字。

## Impact

- `skills/mxcat-commit/references/single-commit.md`、`skills/mxcat-commit/references/batch-commit.md` 的 PowerShell 调用与提交后自检
- `skills/mxcat-commit/scripts/validate.ps1` 的 `Read-CommitMessage`；`scripts/commit_one.ps1` 只经由该函数读说明
- `skills/mxcat-commit/CHANGELOG.md`
- shell 版 `commit_one` / `validate` 不变
- 可执行位、符号链接与路径解析不在本变更内
