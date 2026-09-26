## Why

`--add` 换入在几条路径边上仍会丢工作区、提交错误内容，或在该提交时直接失败。同一路径写两次时，后一次备份盖掉调用前的工作区。已暂存的删除会被 `git add` 拒绝。删除已暂存但文件又出现在工作区时，提交的是新文件。改名后内容再进 index、不再被识别为 rename 时，两个路径的 `--add` 再次失败。只传改名旧路径时，跳过 `git add` 之后会提交成删除。copy 的旧路径被同一判断提前跳过，未暂存内容会进历史。

## What Changes

- `--add` 时，折成同一仓库相对路径的参数只换入一次。恢复用第一次备份，也就是调用前的工作区。index 与 HEAD 相同、只是重复 `git add` 的路径不去重掉第一次暂存。
- 已暂存的删除（HEAD 有该路径、index 与工作区都没有）可以 `--add`。不对该路径执行 `git add`，commit 是这次删除。工作区里尚未暂存的删除仍由 `git add` 收进 index。
- 删除已暂存、工作区又出现该文件时，不论是否带 `--add`，commit 都是这次删除。工作区里后出现的内容在返回后仍在，不进入历史。提交前先挪走该文件，失败退出时放回。
- 已暂存改名在相似度下降、`git diff --cached -M` 不再报 rename 时，新旧路径都列入的 `--add` 仍能创建 commit。旧路径按已暂存删除处理，不执行 `git add`。
- 只传入已暂存 rename 的旧路径、新路径不在参数里时，在创建 commit 之前退出。不提交删除，index 保持这次改名。新旧路径都在时，commit 仍是一次 rename。
- 相似度已低到 git 把它看成删除加新增时，只传旧路径仍按已暂存删除提交。不把「凡是暂存删除都拒绝」用来堵住这个口子。
- copy 的旧路径仍在工作区与 index 中，不按 rename 旧路径跳过。有未暂存改动时只提交 index，否则 `git add`。
- sh 与 PowerShell 入口行为一致。
- 不改工作区与 index 已经一致时的普通 `--only` 提交。不改「index 与 HEAD 相同、只工作区有改动」时 `--add` 提交全文。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: `--add` 对同一路径只换入一次；已暂存删除可以 `--add`；删除已暂存但文件又出现时提交删除并留下工作区；相似度下降后的改名仍可 `--add` 两个路径；只给 rename 旧路径时在提交前退出；copy 旧路径不按 rename 跳过。

## Impact

- 修改 `skills/mxcat-commit/scripts/commit_one` 与 `commit_one.ps1`。
- 在 `skills/mxcat-commit/tests/check_scripts` 覆盖上述路径边。
- 修改 `references/troubleshooting.md`，以及 `references/single-commit.md`、`references/batch-commit.md` 里对 rename / delete 的 `--add` 说明。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不改预览门禁、消息来源，以及失败时恢复 index 的行为。
