## Why

预览后的收尾提示语没有固定文案，agent 各自拼词，还把「合为一条」和「跳过预览」混在一起。确认词与启动语靠一份静态黑名单区分，用户第一次说「提交 / 帮我提交」出预览后，再说「提交」却不被当成批准。同时技能没有可选 push，也没有「不要提交某一条、文件留在工作区」。

## What Changes

- **BREAKING**：确认词从「确认 / 可以提交 / lgtm / 就这样」改为按会话阶段判定。本轮尚未出预览时，「提交」「帮我提交」「commit」等只触发技能并出示预览；预览已出示后，「提交」「确认提交」「帮我提交」视为批准 commit，「提交并 push」视为批准 commit 且随后 push。
- **BREAKING**：废止「完整标题 + 直接提交」即可跳过预览。默认均须预览；仅当用户强调不需要预览（如「不需要预览」「跳过预览」「不要预览」）才允许跳过。
- 预览卡之后 MUST 输出一段固定中文收尾，不得临场改写。
- 用户要求不要提交第 N 条时：从预览拿掉该条，对应文件留在工作区，禁止默默 `git restore` / `checkout` / `reset` 那些文件，重出剩余整单并再次等待确认。
- 用户在预览后说「提交并 push」时：全部 commit 成功后再 `git push` 一次；中途失败则不 push。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-preview-gate`: 阶段确认、固定收尾文案、丢掉预览条目、仅在用户强调不需要预览时跳过。
- `mxcat-commit-workflow`: 批准「提交并 push」后在全部 commit 成功时一次 push；丢掉的条目文件留在工作区；允许的 git 命令包含 `git push`（仅此场景）。

## Impact

- 修改 `skills/mxcat-commit/SKILL.md` 预览门禁摘要，以及 `references/single-commit.md`、`references/batch-commit.md` 的预览模板与确认表。
- 可能小幅更新 `references/troubleshooting.md`（push 无上游、丢掉条目后无剩余项）。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录行为变更。
- 不新增脚本或批次执行器；仍用文档约束 agent。
- 已习惯回复 lgtm / 就这样 的用户需要改用「提交」或「确认提交」。
