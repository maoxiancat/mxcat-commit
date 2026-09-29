## Why

在 Windows PowerShell 5.1 上按 mxcat-commit 的文档再开一个 `powershell.exe` 来接提交说明时，父会话用 US-ASCII 把管道编码，中文在进入 `commit_one.ps1` 之前就变成问号。同时控制台按 gb2312 解码 Git 的 UTF-8 路径，含非 ASCII 字符的仓库根（例如 `杂`）会变成无效的 `git -C` 参数；这些失败被吞掉后，脚本仍用当前目录完成提交，于是文件进了历史、说明却是问号。本地已有一条这样的提交（`a0e0954`，尚未推送），说明这条路径现在就会发生。

## What Changes

- `commit_one.ps1` 在调用 Git 之前把控制台输入输出设为无 BOM 的 UTF-8，使 `git rev-parse` 得到的仓库根与真实路径一致
- 提交说明在当前 PowerShell 进程内通过管道交给脚本，不再经子进程 `powershell -NoProfile -File` 的 US-ASCII 管道
- `git -C <仓库根>` 失败时在创建 commit 之前退出，不再退回「当前目录碰巧能 `git add` / `git commit`」
- 技能文档中的 Windows 调用示例改为同一进程内的 `& commit_one.ps1`

## Capabilities

### New Capabilities

- `powershell-commit-encoding`: Windows PowerShell 提交入口保留非 ASCII 提交说明与仓库路径，并在仓库根无法用于 `git -C` 时停止

### Modified Capabilities

- 无

## Impact

- `.agents/skills/mxcat-commit/scripts/commit_one.ps1`：编码设置、说明读取、`git -C` 失败即停
- `.agents/skills/mxcat-commit/references/batch-commit.md` 与 `single-commit.md`：PowerShell 调用示例
- 不改变 sh/bash/zsh 的 `scripts/commit_one`，不改变提交消息的标题骨架与预览门禁
- 已存在的本地提交 `a0e0954` 不由本变更自动改写；撤回后按新入口重提是使用方的单独操作
