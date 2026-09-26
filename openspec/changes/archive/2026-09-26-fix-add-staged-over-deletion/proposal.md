## Why

文件已在 HEAD 中、index 里有暂存修改、工作区里该文件又被删掉时，`commit_one --add` 会执行 `git add`，把暂存内容盖成整文件删除。这条 commit 成功退出，暂存的那一截没有进入历史。不带 `--add` 已经提交 index 并留下工作区缺失，默认的 `--add` 与这条规则相反。

## What Changes

- index 相对 HEAD 已有改动、工作区中该路径已不存在时，`--add` 不再 `git add`。commit 记录 index 中的模式与 blob，返回后工作区仍没有该路径。创建 commit 之前失败时，工作区仍缺失，index 回到调用前。
- index 与 HEAD 相同、只是工作区删了该路径时，`--add` 仍 `git add`，commit 仍是这次删除。
- 尚未进入 HEAD 的新文件只在 index 中、工作区已删掉时，`--add` 仍在创建 commit 之前退出，不创建 commit，index 回到调用前。
- 已暂存删除、删除后又出现的文件、rename 只给一侧，都不改。
- sh 与 PowerShell 入口使用同一判断。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: index 已有改动且工作区文件缺失时，`--add` 提交 index 并留下缺失；index 与 HEAD 相同时仍把工作区删除收进 commit；仅 index 中的新文件被工作区删掉时，`--add` 仍在提交前退出。

## Impact

- 修改 `skills/mxcat-commit/scripts/commit_one` 与 `commit_one.ps1`。
- 在 `skills/mxcat-commit/tests/check_scripts` 覆盖上述三条路径，以及提交前失败时工作区仍缺失。
- 修改 `references/troubleshooting.md`，以及 `references/single-commit.md`、`references/batch-commit.md` 里对 `--add` 与工作区删除的说明。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不改预览门禁、消息来源，以及已暂存删除、rename、copy 的现有规则。
