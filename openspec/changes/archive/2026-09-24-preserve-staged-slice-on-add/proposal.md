## Why

默认整棵工作树会带 `--add`，入口对每个路径先执行 `git add --`。文件只暂存了一截时，这条 commit 带上的是工作区全文，没暂存的改动被一起提交。已经 `git mv` 的改名再 `--add` 旧路径和新路径时，`git add --` 旧路径匹配不到文件，退出码 128，commit 创建不出来。

## What Changes

- **BREAKING** 带 `--add` 时，若某路径的 index 相对 HEAD 已有改动、工作区还有更多改动，这条 commit 只提交 index 里的模式与 blob，未暂存部分留在工作区。不再用工作区全文盖掉这一截。
- 带 `--add` 时，index 与 HEAD 相同、或路径尚未进入 index 的整文件，仍先 `git add --`，把工作区全文纳入这条 commit。
- 已暂存的 rename 可以 `--add` 旧路径和新路径，并提交成一次 rename。旧路径已不在工作区、也不在 index 时，不再对它执行 `git add --`。
- 不带 `--add`、以及 `--hunks` 的成功路径保持不变。没有创建 commit 时，index 仍恢复到调用前。
- sh 与 PowerShell 入口行为一致。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 默认 `--add` 在部分暂存时提交 index 那一截，而不是工作区全文；已暂存 rename 可以带着 `--add` 用旧路径和新路径提交。

## Impact

- 修改 `skills/mxcat-commit/scripts/commit_one` 与 `commit_one.ps1`。
- 修改 `references/single-commit.md` 与 `references/batch-commit.md`：部分暂存时 `--add` 不再把未暂存改动一并提交；已暂存 rename 可以 `--add`。
- 修改 `openspec/specs/mxcat-commit-workflow/spec.md` 中「合为一条时提交工作区全文」和「整文件路径必须先 `git add --`」的要求。归档时写入主规格。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该行为变化。
- 不改预览门禁、消息来源，也不改不带 `--add` 时提交 index blob 的路径。
