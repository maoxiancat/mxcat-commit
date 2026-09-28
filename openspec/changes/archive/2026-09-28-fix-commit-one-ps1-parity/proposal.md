## Why

Windows PowerShell 上按 guide 把中文说明管道给 `commit_one.ps1` 时，说明会在进 `git commit` 之前被写坏：父进程按 UTF-8 送出、子进程按 GBK 读入时，「增加」变成「澧炲姞」；父进程按 ASCII 送出时变成问号。header 仍然合格，commit 已经创建。`commit_one.ps1` 还有几处换入和路径行为与 shell 版 `commit_one` 不一致，部分提交会留下错误模式、丢掉符号链接，或把仓库内路径拒掉。这些都发生在写入边界上，生成时对照预览文字发现不了。

## What Changes

- 文档中的 Windows PowerShell 调用必须把本次生成的说明（含简体中文）原样送进新建 commit。问号和「澧炲姞」这种代码页误读不得写入 commit。
- `commit_one.ps1` 与单独运行的 `validate.ps1` 按 UTF-8 字节读跨进程标准输入，不再先用系统 OEM 代码页把管道解码成字符串。
- `--hunks` 按行切开补丁，与 shell 版一样能提交完整 hunk 子集。现有「按 hunk 拆分」要求不变，只修实现。
- 换入时保持 `100644` / `100755` / `120000`。`core.filemode=true` 时不得把 `100755` 提交成 `100644`。
- 符号链接换入失败且尚未创建 commit 时，工作区里原来的路径必须还在。
- PowerShell 的 Windows 路径分支必须解析目录符号链接。经符号链接进入仓库的绝对路径与 shell 版 `cd -P` 一样视为仓库内。
- 不拿掉 `commit_one` / `validate` 脚本，也不把这几项改成生成时的自检清单。

## Capabilities

### New Capabilities

### Modified Capabilities

- `mxcat-commit-workflow`: 文档中的 PowerShell 管道必须保持说明原文；换入失败时恢复工作区路径；Windows 分支把经目录符号链接进入仓库的绝对路径视为仓库内。

## Impact

- `skills/mxcat-commit/scripts/commit_one.ps1`、`skills/mxcat-commit/scripts/validate.ps1`
- `skills/mxcat-commit/references/single-commit.md`、`skills/mxcat-commit/references/batch-commit.md` 里的 PowerShell 调用示例
- `skills/mxcat-commit/CHANGELOG.md`
- shell 版 `commit_one` / `validate` 的检查规则不变
- 预览门禁、回执、消息骨架不变
