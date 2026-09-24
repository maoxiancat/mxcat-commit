## Context

见 `proposal.md` 的 Why，行为要求见 `specs/mxcat-commit-workflow/spec.md`。`commit_one` 与 `commit_one.ps1` 在 `--add` 时对每个整文件路径执行 `git add --`，再 `git commit --only`。不带 `--add` 时，入口已经会记下 index 的模式与 blob，换入提交，并在返回后把工作区留在调用前。

## Goals / Non-Goals

**Goals:**

- `--add` 对「index 已不同于 HEAD、工作区还有更多改动」的路径，走现有的 index blob 提交流程。
- `--add` 对已暂存 rename 的旧路径不再执行 `git add --`，新旧路径一起仍能交成一次 rename。
- sh 与 PowerShell 的分类规则相同。

**Non-Goals:**

- 不改不带 `--add` 的成功路径，也不改 `--hunks`。
- 不改「工作区已回到 HEAD、index 里还有另一版」时 `--add` 拒绝提交的行为。
- 不改未创建 commit 时的 index 恢复。
- 不新增参数，也不让技能在部分暂存时改走「只要暂存区」的调用方式。

## Decisions

### 1. `--add` 按路径分类，部分暂存不执行 `git add`

对每个整文件路径，在 `git add` 之前看 index 与 HEAD、以及工作区相对 index：

- index 的模式与 blob 相对 HEAD 有差异，且工作区相对 index 还有差异：不 `git add`。把该路径交给现有的「记下 index 模式与 blob、换入后提交、返回时恢复工作区」路径。
- index 与 HEAD 相同，或路径尚未进入 index：仍 `git add --`，提交工作区全文。

这样未暂存的新文件和整文件改动继续靠 `--add` 进入 commit。部分暂存不再被工作区全文盖掉。

备选：技能在发现部分暂存时去掉 `--add`。同一条里若还有 untracked，不带 `--add` 会把它们留在工作区。分类放在入口里，一条调用可以混着两种路径。

### 2. 已暂存 rename 的旧路径跳过 `git add`

`git mv` 之后，旧路径不在工作区，也不在 index。`--add` 仍会收到旧路径和新路径。对这种旧路径不执行 `git add --`，路径仍传给 `git commit --only`。index 里已有的 rename 保持不动，文件集合对照继续用 `name-status` 读出旧路径和新路径。

新路径若工作区与 index 一致，`git add --` 只是刷新，可以执行。新路径若在 rename 之后又有未暂存改动，按决策 1 提交 index 里的 blob，不把工作区全文盖进去。

备选：对旧路径改用 `git add -A` 或 `git add -u`。旧路径已经不在 index 时，这两种写法仍可能报 pathspec，或把已暂存的 rename 拆开。

### 3. 两个入口共用同一分类

sh 在现有 `--add` 循环里按路径分流。PowerShell 在 `$add` 分支里做同样的分流，部分暂存写入已有的 `$pending`，不再放进 `$whole`。不把分类抽成第三种脚本。

## Risks / Trade-offs

- [同一条里既有部分暂存、又有要 `git add` 的路径] → 只对部分暂存和 rename 旧路径跳过 `git add`，其余路径仍先暂存再对照文件集合。
- [跳过 `git add` 后，旧路径不出现在 `--cached` 的 name-status] → 只跳过 index 里已经记成 rename 旧路径的参数；未暂存的改名仍走 `git add`。
- [调用方以为 `--add` 永远等于工作区全文] → `single-commit.md` 与 `batch-commit.md` 写明部分暂存时只提交 index 那一截。

## Migration Plan

改两个入口、两份流程说明和 CHANGELOG。不改历史 commit，调用方不需要新参数。回滚是恢复这些文件。
