## Context

见 `proposal.md` 的 Why。`--add` 在工作区文件还在、且 index 相对 HEAD 已有改动时，把该路径记入 pending，提交前换成 index 的模式与 blob，退出时按记录放回。工作区文件已经不在时，这条判断进不去，两个入口都落到 `git add`。

换入记录里，调用前路径不存在记为缺失。提交时先按 blob 写出，结束时删掉。失败退出走同一份恢复。

## Goals / Non-Goals

**Goals:**

- 工作区缺失且 index 相对 HEAD 已有改动时，`--add` 走现有的 index 换入，不 `git add`。
- index 与 HEAD 相同的工作区删除仍 `git add`。
- 尚未进入 HEAD 的新文件在工作区缺失时，仍走现在的提交前退出，不改成提交 index。
- sh 与 PowerShell 使用同一判断。

**Non-Goals:**

- 不改已暂存删除、删除后又出现的文件、rename、copy。
- 不改 index 与 HEAD 相同、工作区文件仍在时的全文 `--add`。
- 不改成 `git commit-tree`，也不替换仓库的真实 index。

## Decisions

### 1. 只在 HEAD 有该路径且 index 与 HEAD 不同时跳过 `git add`

工作区没有该路径时，先看 index 与 HEAD 的模式和 blob。HEAD 有该路径，且模式或 blob 与 index 不同，就记入 pending，不 `git add`。只改了模式、blob 相同，也算不同。换入沿用「调用前路径不存在」的记录：提交前写出 index 的内容，返回后删掉，创建 commit 之前失败时同样删掉并把 index 拷回。

index 与 HEAD 的模式和 blob都相同，仍 `git add`，commit 是这次删除。

尚未进入 HEAD、只有 index 有该路径时，不记入 pending。继续现在的 `git add`，随后文件集合对不上，在 `git commit` 之前退出，index 由失败恢复拷回。

备选：工作区只要缺失就提交 index。那样新文件被删掉也会进历史，和「这次提交不做成」相反。

### 2. PowerShell 不再把「工作区没有」一律放进 `git add`

sh 在工作区文件不存在时落到循环末尾的 `git add`。PowerShell 在工作区没有时直接进入待添加列表。两边都改成决策 1 的三分支，判断发生在 `git add` 之前。

备选：只改 sh。两个入口会再次分叉。

## Risks / Trade-offs

- [换入写出文件后，失败恢复没删掉] → 缺失记录的恢复本来就是删掉写出的文件。提交前失败与成功返回走同一份。
- [提交 index 之后工作区仍缺失，下一次 `--add` 把删除收进去] → 这次 commit 之后 index 与 HEAD 相同，下一次落进「仍 `git add`」那一支。删除留到下一次，不是这一次盖掉暂存内容。
- [新文件分支被收成提交 index] → 判断要求 HEAD 里已经有该路径。没有 HEAD 条目的不进 pending。

## Migration Plan

只改两个入口脚本、`tests/check_scripts`、`troubleshooting.md`、`single-commit.md`、`batch-commit.md` 和 CHANGELOG。已有历史 commit 不改写。调用方不需要新参数。回滚是恢复这两个脚本。
