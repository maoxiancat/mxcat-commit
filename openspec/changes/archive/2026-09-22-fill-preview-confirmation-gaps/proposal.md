## Why

预览后的确认被写成几句带引号的原词，用户说「好的，提交吧」时 agent 会卡住；「只提交 commit 1」「提交 1 和 3，2 先留着」、以及改标题同时说提交，规范里都没有。固定收尾太长，模型偶尔改字。

## What Changes

- 预览已出示后，确认改为这句话是不是在下令做 commit（独立的「提交」），不再要求等于「提交」两个字。「提交吧」「那就提交」「好的，提交吧」「可以提交」预览后算批准。单独的「确认」「可以」「好的」「行」「ok」「lgtm」「就这样」，以及「可以提交吗」这类疑问，仍不算。
- 预览后点名只提交某几条（「只提交 commit 1」「提交 1 和 3，2 先留着」）当场做被点名的条；没点名的当丢掉，文件留工作区，不必再出一张剩余预览。只有丢掉、没有批准剩余时，仍重出再等。
- 同一句里改标题 / emoji / scope / 正文并说了提交：改完按新稿提交。拆开、合并、合为一条即使带「提交」也先重出（新稿用户还没看过）。
- **BREAKING**：固定收尾改为更短的一句原文：尚未提交。回复「提交」或「提交并 push」。仍须逐字，不允许等价句。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-preview-gate`: 独立「提交」判定；子集当场做；改字与提交可同一句；拆合仍先重出；收尾缩短。
- `mxcat-commit-workflow`: 子集按原序只做被点名的条；剩余条目不自动重出预览；回执说明还留在工作区的条。

## Impact

- 修改 `SKILL.md` 预览门禁，以及 `references/single-commit.md`、`references/batch-commit.md` 的第 4 步确认表与预览模板收尾。
- `references/troubleshooting.md` 若仍引用旧确认词或旧收尾，一并改掉。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录确认判定、子集提交与收尾原文。
- 不新增脚本或执行器；不恢复 `lgtm` / `就这样` 为确认词；不改 `--only`、密钥提醒或回执字段结构。
