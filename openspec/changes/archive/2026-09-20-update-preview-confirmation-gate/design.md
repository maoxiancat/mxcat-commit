## Context

技能包已存在：`SKILL.md` 作路由器，预览门禁摘要在默认加载层，单次/分批细节在 `references/single-commit.md` 与 `references/batch-commit.md`。预览卡是对话里的 Markdown，没有 plan JSON 或执行脚本。见 `proposal.md` 的 Why；行为合同见本 change 的 delta specs。

当前确认靠静态词表（确认 / lgtm / 就这样），跳过预览靠「完整标题 + 直接提交」，收尾文案未写死，也不描述 `git push` 或「丢掉某条」。

## Goals / Non-Goals

**Goals:**

- 把预览后收尾写成唯一原文，写进默认加载层和两份预览模板。
- 用会话阶段解释「提交 / 帮我提交」，而不是维护与阶段无关的黑名单。
- 确认表、跳过条件、丢掉条目、一次 push 与 delta specs 对齐，避免口头 CTA 和 guide 表不一致。
- 继续只用文档约束 agent，不引入 push/commit 脚本。

**Non-Goals:**

- 不恢复 lgtm / 就这样 为规范确认词。
- 不实现 force push、自动 `git push -u`、或每条 commit 后 push。
- 不把丢掉预览条目做成 `git restore` / 丢弃工作区改动。
- 不改变 cz-emoji 消息约定、默认 batch 分流、或安装/打包方式。

## Decisions

### Decision: 固定收尾原文只定义一次，三处复述

规定原文放在 `SKILL.md` 预览门禁（默认一定读到）。`single-commit.md` 与 `batch-commit.md` 的预览模板在最后一条卡之后用同一段跟出，作为 agent 输出样例。single 与 batch 不写两套话。收尾独立成段，不放进「解释」。

Alternatives considered:

- 只改 guide、不改 `SKILL.md`：未读到对应 guide 时仍会临场发挥。
- 只改 `SKILL.md`：预览模板没有收尾，agent 容易只抄「标题 / 正文 / 解释」就停。

### Decision: 确认按「本轮是否已出预览」分阶段

默认加载层写明：尚未出示预览时，「提交」「帮我提交」「commit」等只出预览；已出示后，「提交」「确认提交」「帮我提交」批准 commit，「提交并 push」批准 commit 且随后走一次 push。预览后的「帮我提交」与「提交」同等，避免用户用同一句话触发后再确认时卡住。不再把 lgtm / 就这样列为确认词。

「合为一条」仍是改走 single 并重出预览，不是跳过门禁。

Alternatives considered:

- 继续「帮我提交永远不是确认」：与用户「预览后再说提交就提交」冲突。
- 预览后仍不认「帮我提交」：同一句话第二次会被当成无效。

### Decision: 丢掉某条只改预览计划，不动那些文件的 git 内容

从预览移除第 N 条，文件留在工作区，整单（含收尾）重出后再等批准。禁止对这些文件 `git restore` / `checkout` / `reset`。只剩 0 条则停止。这是计划编辑，不是撤销已有 commit。

### Decision: push 是确认动作上的可选后缀，不是默认提交流程

只有预览后的「提交并 push」才 `git push`。顺序：全部预定 commit 成功 → 恰好一次 `git push` 当前上游。无 `--force` / `--force-with-lease`；无上游则报告、不擅自 `-u`。batch 中途失败不 push。只说「提交」则不 push。

`git push` 写进 batch/single 的确认后步骤，以及 troubleshooting 的无上游分支；不写进每次必跑的命令列表。

### Decision: 跳过预览只认「强调不需要预览」

废止「完整标题 + 直接提交」。用户必须明确说不需要预览 / 跳过预览 / 不要预览。此时 agent 自拟合规消息并提交，无预览卡、无收尾。

## Risks / Trade-offs

- [Risk] 阶段规则仍只靠文档，agent 可能把第一次「提交」直接当成 commit。  
  Mitigation: `SKILL.md` 用「尚未预览 / 已出预览」对照写，两份 guide 第 4 节用同一张确认表，预览模板末尾跟死收尾。

- [Risk] 「提交」与启动语「帮我提交」相近，漏看阶段会误提交。  
  Mitigation: 规范写明启动语集合在未预览阶段一律只出卡；已预览阶段才把「提交」「帮我提交」当批准。

- [Risk] 旧用户回复 lgtm / 就这样会得不到提交。  
  Mitigation: CHANGELOG 标明确认词变更；收尾只引导「提交」「提交并 push」。

- [Risk] 「提交并 push」在无上游或部分 commit 失败时，用户以为已经推送。  
  Mitigation: 失败或不 push 必须报告；禁止假装 push 成功。

- [Trade-off] 丢掉条目后不还原文件，工作区可能留下用户以为已经「删掉」的 diff。  
  Mitigation: 重出的预览不再包含该条，口头说明文件仍留在工作区。

## Migration Plan

1. 先改 `SKILL.md` 预览门禁（阶段、原文收尾、新跳过条件），技能在只读主文档时行为已转向。
2. 再改 single / batch 模板与确认表，以及 troubleshooting 的 push / 空预览。
3. 在技能 CHANGELOG 记录确认词与跳过条件的破坏性变化。
4. 无需数据迁移或配置文件；回滚即还原上述 markdown。
