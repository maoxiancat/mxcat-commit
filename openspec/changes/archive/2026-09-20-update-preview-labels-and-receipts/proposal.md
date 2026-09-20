## Why

预览卡仍用 `待确认 · 1/N`，和收尾里的「某个 commit」对不上，丢掉一条后编号还会滑动。commit / push 成功后没有规定回执，agent 各自汇报，用户看不到短 hash、统计和远程信息。

## What Changes

- 预览条目标题改为 `## commit 1`、`## commit 2`；单条仍写 `## commit 1`，不再使用 `待确认 · 1/N`。
- 条目编号是稳定身份：丢掉某号后其余保留原号（丢掉 2 后仍是 1、3）。合并吃较小号；拆开时原号留给第一条，新条用从未用过的下一个整数。
- 用户指条目时以标题编号为准（`commit 2`），不以当前列表上的第几张为准。
- 成功路径使用三套带槽位的回执：只提交、提交并 push、提交之后再 push。
- 只提交成功且有 origin 时，回执可邀请稍后 push；用户在 commit 成功后再说「帮我 push」等，技能 MUST 允许一次 `git push`（仍无 force、无擅自 `-u`）。
- 写「工作区应已无未提交变更」前 MUST 先看 `git status`；仍有未提交变更时不得写这句。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-preview-gate`: 预览标题改为 `## commit N`；稳定编号；丢掉/合并/拆开的编号规则。
- `mxcat-commit-workflow`: 三套成功回执；commit 块与 push 所含 hash 的分工；GitHub / 非 GitHub 措辞；提交成功后再 push。

## Impact

- 修改 `references/single-commit.md`、`references/batch-commit.md` 的预览模板、改稿编号说明，以及提交/push 成功后的回执样例。
- 可能在 `SKILL.md` 预览门禁补一句标题形态；在 `troubleshooting.md` 对照成功回执写失败时不得套用。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录预览标题与成功回执。
- 不新增脚本；仍用文档约束 agent。回执是带槽位的模板，不是一字不差的死句子（固定收尾提示语不变）。
