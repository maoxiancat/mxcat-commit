## Why

`commit_one` 在换入 index 或选中 hunk 时，同一路径的两种写法会各换入一次，后一次备份盖掉调用前的工作区，未暂存内容从工作区消失。同一次调用里，`--hunks` 只换入补丁路径，旁边已暂存且仍有未暂存改动的文件走 `git commit --only`，未暂存内容被写进历史。在子目录里，仓库相对路径被当成当前目录下的路径，根目录下能成功的换入会在提交前被拒绝。三次的退出码都是 0，或在创建 commit 之前退出，所以看起来像成功或干净失败。

## What Changes

- 一次调用里，折成同一仓库相对路径的参数只换入一次。恢复用第一次备份，也就是调用前的工作区。
- 不带 `--add` 时，`--hunks` 以外的路径也按 index 换入。index 相对 HEAD 有改动时，commit 只含 index 的模式与 blob，未暂存内容留在工作区。index 与 HEAD 相同但工作区有未暂存改动时，在创建 commit 之前退出。补丁路径仍只换入选中 hunk 对应的条目，不再按完整 index 换第二次。
- 使用仓库相对路径的 `git diff`、`git ls-files`、`git ls-tree`、`git update-index` 从仓库根执行。用户原来的路径参数仍交给最后的 `git commit --only`。
- sh 与 PowerShell 入口行为一致。
- 不改默认 `--add` 的整文件提交。不改工作区与 index 已经一致时的普通 `--only` 提交。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 同一路径的多种写法只换入一次；`--hunks` 与其它只提交 index 的路径可以出现在同一次调用里，那些路径的未暂存内容不得进入 commit；不在仓库根目录时，按 hunk 或只提交已暂存内容的换入仍能成功。

## Impact

- 修改 `skills/mxcat-commit/scripts/commit_one` 与 `commit_one.ps1`。
- 在 `skills/mxcat-commit/tests/check_scripts` 覆盖：同一路径两种写法、`--hunks` 旁路的已暂存文件、子目录中的换入。
- 修改 `references/troubleshooting.md`。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不改预览门禁、消息来源，以及失败时恢复 index 的行为。
