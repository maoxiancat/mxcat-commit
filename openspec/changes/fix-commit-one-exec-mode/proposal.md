## Why

Windows 上 `core.filemode` 为 `false`，工作区文件没有可执行位。`commit_one.ps1` 在换入后执行 `update-index --chmod=+x`，再 `git commit --only`。`--only` 另建一份从 HEAD 加上工作区做出来的 index，看不到刚才写进当前 index 的 `100755`。内容和模式一起提交时，commit 里该路径变成 `100644`，事后检查失败，这条 commit 已经留下。只改了可执行位时，`git diff --quiet` 成功，路径不会进入换入，`--only` 认为没有可提交内容，commit 不会创建。主 spec 已经要求这两种情况的 commit 都是 `100755`。

## What Changes

- 文件系统表达不了普通文件的可执行位时，`commit_one.ps1` 用一份已经写好模式和 blob 的临时 index 创建 commit。要提交的 `100755`，以及要把 `100755` 改回的 `100644`，都走这条路径。不再靠 `update-index --chmod=+x` 配合 `git commit --only`。
- index 与 HEAD 只有模式不同时，也进入这条提交流程。`git diff` 因为 `core.filemode=false` 而安静，不得当成没有可提交的已暂存改动。
- 没有路径需要工作区表达不了的 `100755` 时，仍用现在的 `git commit --only`。
- 提交成功后，真正的 index 与 `--only` 的结果相同：本次路径变成 commit 里的模式和 blob，其它已暂存路径不动。失败且未创建 commit 时，index 与工作区恢复为调用前。
- 不改 shell 版 `commit_one` / `validate`，不改说明读入、预览门禁和消息骨架。

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- `skills/mxcat-commit/scripts/commit_one.ps1`
- `skills/mxcat-commit/CHANGELOG.md`
- shell 版 `commit_one`、`validate`、`validate.ps1` 不变
- 主 spec 的 `100755` 要求不变，本变更只让 PowerShell 在文件系统表达不了该位时达到已有结果
