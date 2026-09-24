## Why

`commit_one` 按 hunk 提交、或不带 `--add` 只提交 index 内容时，会先把工作区路径换成目标 blob，再 `git commit --only`，退出时按备份顺序放回。换成和放回都把路径当成普通文件。同一路径在补丁里出现两次时，后一次备份盖掉原文件，没选中的改动从工作区消失。符号链接和可执行位则按磁盘上的普通文件写进历史，退出码仍是 0。

## What Changes

- 换入、备份、恢复都不跟随符号链接。先删掉路径再写，避免写穿到链接目标。悬空链接也能备份。
- 换入带上 index 的模式和 blob。`100644` 与 `100755` 写字节后按模式改权限。`120000` 按 blob 内容建成符号链接。
- 同一路径在一次调用里只换入一次。恢复用调用前的那一份。
- 不带 `--add` 时，模式和 blob 都与 HEAD 相同才说明没有可提交的已暂存改动。只改了模式就提交这个模式，工作区内容照旧放回。
- 提交后的核对同时看模式和 blob。对不上就非 0 退出。已创建的 commit 仍保留，不自动 `reset`。
- sh 与 PowerShell 入口行为一致。
- 不改默认 `--add` 的整文件提交。不处理改前已存在的边界：默认 `--add` 无法提交已暂存的 rename 或 `git rm`，以及暂存删除后又出现同名未跟踪文件。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 部分提交与只提交 index 内容时，commit 中的类型和模式必须与要提交的条目一致；工作区在返回后仍是调用前的路径形态；只改模式的已暂存改动可以提交。

## Impact

- 修改 `skills/mxcat-commit/scripts/commit_one` 与 `commit_one.ps1`。
- 修改 `skills/mxcat-commit/tests/check_scripts`：覆盖重复 `diff --git`、符号链接、可执行位、悬空链接、只改模式。
- 修改 `references/troubleshooting.md`。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不并入 `restore-index-on-commit-one-failure`。不改预览门禁和消息来源。
