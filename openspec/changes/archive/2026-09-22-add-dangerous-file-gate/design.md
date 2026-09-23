## Context

技能仍是文档约束 agent。提交命令已用 `--only` 锁预览路径，因此预览里写了什么就会提交什么。见 `proposal.md` 的 Why。本次把风险从「默认排除」改为「仍编进预览并提醒」；不改提交命令、不引入执行器。跳过预览如何处理这类路径不在本次范围。

## Goals / Non-Goals

**Goals:**

- 在 `SKILL.md` 路由层点到「预览前提醒从未进过仓库的密钥/个人信息」，细节写进 single / batch。
- 无硬名单；靠「明显是密钥、凭证或个人信息」+「尚未进入 HEAD」决定是否提醒。
- skills 与 binary 默认拆条，合为一条视为允许混入。

**Non-Goals:**

- 不引入执行器、独立 index、shadow worktree、inventory JSON、secret scanner。
- 不改 `--only` 提交命令、失败留下已成功 commit、不自动 reset。
- 不扫描已跟踪文件里的密钥内容。
- 不规定跳过预览时对这类路径的额外行为。

## Decisions

### Decision: 不写硬名单，提醒但不排除

识别靠 agent 判断：路径或内容一看就是密钥、凭证、个人信息。不维护 `.env` / `*.pem` 等 glob 表。分界是路径是否已在 HEAD 中，不是 `??` 与 `A`：staged 新增同样提醒；已跟踪后的修改不因此提醒。

这些路径留在某条「改动部分」里，提醒块放在全部 `## commit N` 之后、固定收尾之前。用户对这张卡说「提交」，就是看过提醒后的批准。不要「未纳入」+ 点名放行。

Alternatives considered:

- 硬名单默认排除：用户已明确不要名单，也不要拦下来。
- 只看未跟踪：`git add .` 之后同样需要提醒。
- 跑 `git log --all -- path` 认「历史上提交过」：超出文档约束体量；用 HEAD 有无该路径即可。

### Decision: 跳过预览不另写规则

既有「强调不需要预览则可跳过卡片」保留，不为密钥/个人信息加例外。本次不描述跳过时是否仍提醒或仍提交这类路径。

### Decision: skills 与 binary 只拆条，不排除

`.agents/skills/*` 默认与业务分开；git 视为 binary（`git diff --numstat` 两列都是 `-`）默认不与功能文件同条，并在解释里点名。二者都可以提交。「合为一个 commit」视为允许混入；batch 下用户明确要求合并时也可以混。

## Risks / Trade-offs

- [Risk] 无名单、靠判断，会漏报或把普通 `auth.ts` 当成个人信息。  
  Mitigation: 提醒不是拦截；漏报不假装扫全；误伤用户说「提交」即可带上。

- [Risk] 提醒块写在收尾前，agent 可能改写固定收尾。  
  Mitigation: 样例把提醒块和收尾分成两段；规格写明 MUST NOT 改收尾原文。

- [Trade-off] 看过提醒后说「提交」就会把 `.env` 写进历史。  
  Mitigation: 这是本设计的显式选择；预览门禁保证至少出示过一次卡片。

## Migration Plan

1. `SKILL.md` 默认路由改为：预览前提醒从未进过仓库的密钥/个人信息。
2. single / batch 去掉硬名单与排除/点名；改成仍编进预览 + 提醒块；保留 skills / binary 拆条。
3. troubleshooting 删除「只剩排除项」「点名放行」两节。
4. CHANGELOG 把本变更记成预览提醒，不改写已发布版本条目正文。
5. 回滚即还原上述 markdown。
