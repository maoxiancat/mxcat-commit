## Why

`commit_one --add` 在 `git commit` 之前就会 `git add`。路径预检失败、夹了被忽略的文件、或 hook 拒绝时，这次调用没有创建 commit，index 却已经离开调用前：有改动的文件被暂存，工作区已回到 HEAD 时 index 里的另一版还会被盖掉。调用方看到失败，暂存区却变了。

## What Changes

- `commit_one` 在第一次改动 index 之前留下调用时的 index。这次调用没有创建 commit 时，退出前把 index 放回那一版。HEAD 不动。
- 覆盖这些失败：`--add` 之后路径集合对不上、`git add` 本身失败（含被忽略的文件）、`git commit` 失败（含 hook 拒绝）、工作区已回到 HEAD 而 index 里还有另一版时 `--add` 再执行 `git add`。
- 成功创建 commit 之后，index 保持 `git commit` 留下的结果，不放回调用前。提交后文件集合或 hunk 对照失败时，已创建的 commit 仍保留，不自动 `reset`。
- 目录参数仍在 `git add` 之前拒绝。该路径不改 index。
- sh 与 PowerShell 入口行为一致。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 没有创建 commit 的失败必须把 index 恢复到调用前；已创建的 commit 仍不自动 reset。

## Impact

- 修改 `skills/mxcat-commit/scripts/commit_one` 与 `commit_one.ps1`。
- 修改 `references/troubleshooting.md`：提交前失败时 index 与调用前一致；提交后对照失败时 commit 仍保留。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不改预览门禁、消息来源、`--hunks` 的工作区恢复，也不改默认 `--add` 提交工作区全文、以及不带 `--add` 时提交 index blob 的成功路径。
