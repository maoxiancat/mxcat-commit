## Why

需要一个可公开发布的个人 commit skill：用 cz-emoji shortcode 标题，分层路由器加 references。别人应能从 GitHub 用 `npx skills add` 安装到 Cursor / Claude 等 Agent。提交必须默认中文、先预览带解释、用户确认后才执行 `git commit`。

## What Changes

- 新增可安装技能包 `skills/mxcat-commit/`，`SKILL.md` 的 `name` 为 `mxcat-commit`。
- 主文档作为路由器：默认按逻辑分批（batch）；仅当用户明确要求合为一条 commit 时走 single。执行细节下沉到 `references/`。
- 提交消息采用 cz-emoji shortcode 标题，且 `(scope)` 必写；subject 与 body 默认简体中文；不输出 `AI-Co-Authored-By` 或 `Jira-Refs:`。
- single 与 batch 都先出示预览卡（标题、正文、解释），等待明确确认后才提交；启动语「帮我提交」不等于确认。
- batch 由 agent 手工分组并一次预览多条，用常规 git 命令提交。
- 仓库 README 提供公开 `npx skills` 安装命令（项目级与 `-g` 全局、多 `-a` Agent）；托管目标为 GitHub。
- 实现按切片推进：先空壳可发现，再约定、路由器、single、batch、附录，最后再接 GitHub 远程。

## Capabilities

### New Capabilities

- `mxcat-commit-packaging`: 技能包目录、frontmatter、安装文案，以及通过 GitHub + `npx skills` 被发现和安装到多种 Agent 的约定。
- `mxcat-commit-message-convention`: cz-emoji header 骨架、默认中文描述、footer 禁令与语言覆盖规则。
- `mxcat-commit-preview-gate`: 预览卡结构、解释范围、确认 / 修改 / 跳过预览的门禁。
- `mxcat-commit-workflow`: single / batch 分流、渐进式披露读取路径，以及无脚本的分批提交流程。

### Modified Capabilities

- 无。仓库尚无主 specs。

## Impact

- 新增 `skills/mxcat-commit/`（`SKILL.md`、`README.md`、`CHANGELOG.md`、`references/`）和仓库根 `README.md`。
- 不新增批次执行器或测试套件。
- GitHub 源为 `maoxiancat/mxcat-commit`。
