## Why

默认输入是整棵工作树，明显是密钥、个人信息、且从未进过仓库的路径会静默编进预览并提交，用户在确认前看不见风险。`.agents/skills/*` 和二进制也会跟业务代码混在一起。

## What Changes

- 出预览前识别明显是密钥、凭证或个人信息、且尚未出现在 HEAD 中的路径（未跟踪或 staged 新增）。不要硬名单。这些路径 MUST 仍编进某条预览的「改动部分」，MUST 在预览中提醒用户：确认提交会把它们写进历史。已跟踪路径的修改 MUST NOT 仅因此提醒。
- 提醒块放在全部 `## commit N` 之后、固定收尾之前。无此类路径则不要该块。用户对已含提醒的预览说「提交」即视为看过提醒后的批准，不必再点名放行。
- 本次不规定跳过预览时如何处理这类路径。
- `.agents/skills/*` 与业务代码默认拆成不同预览条目；git 视为 binary 的路径默认不与功能文件写进同一条，并在预览中点名。用户明确要求合并时允许。
- 不引入执行器、独立 index、shadow worktree 或 secret scanner。提交仍用已落地的 `--only` 锁预览路径。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 密钥/个人信息仍编进预览；skills 与二进制默认拆条。
- `mxcat-commit-preview-gate`: 预览必须提醒从未进过仓库的密钥与个人信息。

## Impact

- 修改 `SKILL.md` 默认路由（简短点到预览前提醒），以及 `references/single-commit.md`、`references/batch-commit.md` 的分析/分组与预览步骤。
- `references/troubleshooting.md` 去掉「排除 / 点名放行」相关节。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该提醒。
- 不新增脚本、测试套件或 Python 依赖。
