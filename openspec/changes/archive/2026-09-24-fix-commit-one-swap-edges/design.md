## Context

见 `proposal.md` 的 Why。不带 `--add` 时，工作区与 index 不一致的路径被记入 pending，提交前换成 index 的模式与 blob，退出时按记录顺序放回。`--hunks` 只把补丁路径写入 pending。随后 `git commit --only` 对没换入的路径提交工作区。

sh 在 `elif [ -z "$hunks" ]` 里才做 index 换入，并按每个原始参数各追加一条 pending。PowerShell 的对应分支是 `elseif ([string]::IsNullOrEmpty($hunks))`，pending 列表同样不去重。仓库相对路径上的 `git diff`、`git ls-files`、`git ls-tree`、`git update-index` 多数没有 `git -C` 仓库根。PowerShell 里生成完整 diff 的那次已经用了 `-C`。

仍用 `git commit --only`。用户原来的路径参数继续交给这次 commit。

## Goals / Non-Goals

**Goals:**

- 折成同一仓库相对路径的参数只产生一份调用前备份。
- `--hunks` 以外、不带 `--add` 的路径与单独只提交 index 时使用同一判断。
- 这些判断在子目录里看到的是仓库相对路径，而不是当前目录下的路径。

**Non-Goals:**

- 不改默认 `--add` 的整文件路径。
- 不改工作区与 index 已经一致时直接 `--only` 的路径。
- 不改成 `git commit-tree`，也不替换仓库的真实 index。

## Decisions

### 1. 按折好的路径去重，只保留第一次

pending 在追加前看该仓库相对路径是否已经在列。已在列则跳过，包括补丁路径和稍后按 index 追加的路径。恢复顺序不变，每个路径只有第一次备份。

备选：换入时若路径已换过就跳过。调用前的备份同样能留下，但第二次若带着另一个 blob，跳过会发生在错误条目已经入队之后。入队时去重能让补丁条目盖住后来的完整 index。

### 2. 有 `--hunks` 时，补丁外路径仍走 index 换入

去掉「没有 hunks 才判断」这个条件。不带 `--add` 时，对每个尚未进入 pending 的路径：

- 工作区与 index 一致：不换入，留给 `git commit --only`。
- index 的模式与 blob 都与 HEAD 相同，但工作区还有未暂存改动：在创建 commit 之前退出，说明没有可提交的已暂存改动。
- index 相对 HEAD 有改动：把该 index 条目追加进 pending，再换入。

补丁路径已经在 pending 里，这一步跳过，避免用完整 index 盖掉选中 hunk。

备选：`--hunks` 与其它路径分两次 `commit_one`。调用方要改，而且一次调用的文件集合会拆开。

### 3. 仓库相对路径的 git 查询从仓库根执行

`git diff`、`git ls-files`、`git ls-tree`、`git update-index` 在参数已经是仓库相对路径时，使用 `git -C <仓库根>`。包括 sh 的 `reject_partial_path`、hunk 校验、index 读取、提交后的 `ls-tree`，以及 PowerShell 里尚未加 `-C` 的 `ls-files`、`ls-tree`、`update-index` 和 `Assert-SplittablePath` 的 diff。

`git diff --quiet`、`git add`、`git commit --only` 仍用用户原来的参数，它们相对当前目录。

备选：pathspec magic `:(top)`。路径里的特殊字符要再转义一层，两个入口更难对齐。

## Risks / Trade-offs

- [同一路径的两种写法，一次有未暂存 diff、另一次在去重前已经被换掉] → 去重发生在换入之前，两次都看到调用前的工作区。
- [子目录里 `git -C` 与用户参数混用，commit 路径对不上] → 只有仓库相对路径的查询改到仓库根。最后的 `--only` 和文件集合对照仍用原来的参数。
- [`tests/check_scripts` 在当前工作区已删除] → 补上这三条用例时，以该脚本为入口；文件不在就先恢复能跑这三条的检查，不顺手改其它用例的断言。

## Migration Plan

只改两个入口脚本、`tests/check_scripts`、`troubleshooting.md` 和 CHANGELOG。已有历史 commit 不改写。调用方不需要新参数。回滚是恢复这两个脚本。
