## Context

见 `proposal.md` 的 Why。`commit_one` 与 `commit_one.ps1` 在 `--add` 时先 `git add` 再 `git commit --only`。路径预检、`git add` 失败和 hook 拒绝都发生在 commit 写入 HEAD 之前或同时失败，但 index 已经离开调用前。现有 `EXIT` trap 只恢复按 hunk 换入的工作区文件。

## Goals / Non-Goals

**Goals:**

- 没有创建 commit 时，index 与调用前逐字节一致。
- 成功创建 commit 后，保留 `git commit` 留下的 index，包括未列入本次路径的已暂存文件。
- sh 与 PowerShell 的失败语义相同。

**Non-Goals:**

- 不自动 `reset` 已创建的 commit。
- 不改默认 `--add` 提交工作区全文，也不改不带 `--add` 时提交 index blob。
- 不把 `GIT_INDEX_FILE`、stash 或 `git reset` 用于创建 commit。
- 不撤销 hook 对工作区文件的改写。hunk 换入的工作区恢复保持现状。

## Decisions

### 1. 复制备份真实 index 文件，失败时再拷回

在第一次可能改动 index 的操作之前，把 `git rev-parse --git-path index` 拷到本次调用的临时文件。没有创建 commit 就退出时，把这份拷贝写回原路径。

这样保留 stage 标志、skip-worktree、intent-to-add，以及工作区已经回到 HEAD 时 index 里的另一版 blob。

备选：`git write-tree` 再 `git read-tree`。unmerged index 会失败，也会丢掉上述标志。`git reset` 会动 HEAD 或工作区，与「HEAD 不动」冲突。

创建 commit 仍使用仓库的真实 index。临时拷贝只用于恢复，脚本不设置 `GIT_INDEX_FILE`。hunk 补丁继续用单独的临时 index 读 blob，不替换这份备份。

### 2. 只有 git commit 成功之后才放弃恢复

用一个标志记下 `git commit` 是否已经成功。标志在 `git commit` 返回 0 之后、提交后对照之前置上。`EXIT` / `finally` 在标志未置上且备份存在时拷回 index，然后再做现有的工作区恢复。

提交后对照失败时标志已经置上，commit 保留，index 保持提交后的内容。`git add` 或 `git commit` 因 `set -e`、忽略文件或 hook 退出时，标志未置上，trap 负责拷回。

备选：每个失败分支手写恢复。漏掉 `set -e` 的退出路径时，index 仍会留下半次 `git add`。

### 3. 目录预检仍在备份之前

目录参数在 `normalize_arg` 里拒绝，此时尚未备份、也尚未 `git add`。这条路径 index 本来就没变。备份从通过路径预检、即将 `git add` 或 `git commit` 之前开始。

## Risks / Trade-offs

- [提交后对照失败却仍执行了恢复] → 标志紧挨 `git commit` 成功置上，对照在其后。
- [index 文件被占用，拷回失败] → 恢复失败时保持非 0 退出，不把这次调用报成成功。
- [hook 改了工作区] → 只恢复 index。hunk 换入的文件仍走现有工作区备份。
- [split index 等旁路文件] → 以 `git rev-parse --git-path index` 指向的文件为准。

## Migration Plan

只改两个入口脚本、`troubleshooting.md` 和 CHANGELOG。已有历史 commit 不改写。调用方不需要新参数。回滚是恢复这两个脚本。
