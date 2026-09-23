## 1. 路由与分析分组

- [x] 1.1 在 `SKILL.md` 默认路由（`git status --short` 之后）点到：明显是密钥或个人信息、且尚未进入 HEAD 的路径，预览里提醒；不要展开名单或命令
- [x] 1.2 改 `references/single-commit.md` 与 `references/batch-commit.md` 的分析/分组：无硬名单；明显密钥/个人信息且尚未进入 HEAD 的仍编进预览；已跟踪修改不因此提醒
- [x] 1.3 同一处保留：`.agents/skills/*` 默认与业务拆条；`git diff --numstat` 两列都是 `-` 的 binary 默认不与功能文件同条并在解释中点名；「合为一条」或用户明确要求合并时允许混入

## 2. 预览提醒

- [x] 2.1 在 single / batch 预览步骤把「未纳入」改为「提醒」块：路径仍在「改动部分」；全部 `## commit N` 之后、固定收尾之前列出；无此类路径则不要该块；不得改写固定收尾
- [x] 2.2 去掉点名放行改稿表项；对已含提醒的预览说「提交」即按预览提交。不为跳过预览单写密钥规则

## 3. 故障说明与 changelog

- [x] 3.1 从 `references/troubleshooting.md` 删除「只剩排除项」和「点名放行后同轮不要提交」
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md` 的 1.1.4 条目：改为预览提醒从未进过仓库的密钥与个人信息，并保留 skills/二进制拆条；不改写已发布版本条目正文
