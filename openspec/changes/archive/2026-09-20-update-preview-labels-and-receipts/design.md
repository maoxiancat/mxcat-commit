## Context

技能仍是文档约束 agent：`SKILL.md` 路由与预览门禁摘要，single/batch 在 `references/`。预览卡是聊天里的 Markdown，没有 plan JSON。固定收尾原文已经定死；本设计只改条目标题形态、编号身份，以及 commit/push 成功后的回执。见 `proposal.md` 的 Why；行为合同见本 change 的 delta specs。

当前模板是 `## 待确认 · 1/N`。成功后没有规定回执。push 只绑在预览确认时的「提交并 push」。

## Goals / Non-Goals

**Goals:**

- 两份预览模板与 batch「只有一组也走 batch」的说明改成 `## commit N`，并写明丢掉/合并/拆开的编号规则。
- 在 single/batch 成功路径放三套回执样例，槽位怎么填写清楚，避免和一字不差的收尾提示语混成同一种约束。
- 确认表允许「提交成功后再 push」；`SKILL.md` 把「只批准提交则不 push」收窄为该次回复。
- 失败路径明确禁止套用成功回执。

**Non-Goals:**

- 不改固定收尾原文、确认词阶段规则、跳过预览条件。
- 不恢复 force push、自动 `git push -u`、或每条 commit 后 push。
- 不引入回执脚本或模板引擎；数字与 URL 由 agent 用普通 git 命令读取后填槽。
- 不改变 cz-emoji 消息约定或默认 batch 分流。

## Decisions

### Decision: 标题形态写进模板，编号规则写进 batch 改稿表

`## commit N` 出现在 `single-commit.md` 与 `batch-commit.md` 的预览样例里。`SKILL.md` 预览门禁只补一句：每条用 `## commit N`，编号是身份、丢掉后不滑动。合并吃较小号、拆开补 `max+1` 的细节放在 batch 第 4 节，避免主文档膨胀。

single 只有一条时仍用 `## commit 1`。batch 逻辑上只有一组时同样 `## commit 1`，不要写回 `1/1`。

Alternatives considered:

- 只改 spec、不改模板：agent 会继续抄 `待确认 · 1/2`。
- 把合并/拆开规则写进 `SKILL.md`：默认加载层会变长，而改稿时已经会读 batch guide。

### Decision: 回执是带槽位的样例，不是死句子

规定原文只留给预览收尾。回执在 single 提交后、batch 整单成功后各放样例；「提交之后再 push」的样例两份 guide 共用同一结构。槽位来源：

- 短 hash / 标题：`git log`（本次新建的那些 commit）
- 文件数与 ± 行：`git show --stat`（或等价 shortstat）；只有插入时写成 `+N 行`，有删除时写成 `+A / -B 行`
- 工作区是否干净：回执前 `git status --short`
- origin URL / owner/repo：`git remote get-url origin`；SSH `git@github.com:owner/repo.git` 与 HTTPS 都要能推出网页地址
- 这次 push 送出的 hash：push 前 `git log <upstream>..HEAD` 的短 hash（无上游则不会走到成功 push 回执）

GitHub：origin 主机为 `github.com`（含 SSH）时用「已推送到 GitHub / 已提交并推送到 GitHub」；否则改「远程」，能推出网页 URL 再写 `仓库地址：`。

Alternatives considered:

- 成功回执也一字不差：hash 和统计无法填。
- 回执全文塞进 `SKILL.md`：三套样例会压过门禁摘要；agent 提交时已经在读对应 guide。

### Decision: 提交成功后再 push 是确认表上的后续动作

「该次回复只批准提交则不 push」保留。只提交成功的回执若有 origin，用「若要推到 owner/repo，可以说一声我帮你执行 git push。」用户随后说「帮我 push」「推一下」「git push」时，对当前上游一次 `git push`，无 force、无擅自 `-u`。成功后用「已推送到 GitHub。」那套（无 `Commit：` 块）。

`SKILL.md` 里现在那句「用户只批准提交、未要求 push 时，不要运行 git push」改成明确是该次回复，并点出随后可 push。

Alternatives considered:

- 继续只认预览时的「提交并 push」：与只提交回执里的邀请矛盾。

### Decision: 失败不得套成功回执

中途 commit 失败、无上游、push 失败仍走 `troubleshooting.md` 的报告方式。在该文件写明：这些情况不要用「提交已完成 / 已提交并推送 / 已推送」开头。commit 都成功但 push 失败时，可用「提交已完成」回执（可邀 push），再另段说明没有推上去。

## Risks / Trade-offs

- [Risk] agent 丢掉一条后把 `commit 3` 改成 `commit 2`。  
  Mitigation: batch 预览样例直接演示 1 与 3；改稿表写「不要填补空号」。

- [Risk] 「第二条」与 `commit 2` 在空号后不一致。  
  Mitigation: spec 规定认标题编号；guide 写优先匹配 `commit N`。

- [Risk] 把更早未推送的 commit 写进 `Commit：` 块，或漏写进分支行。  
  Mitigation: 样例做成「Commit 块一条、分支行两条 hash」，并在旁注释分工。

- [Risk] 丢掉条目后仍写「应已无未提交变更」。  
  Mitigation: 回执步骤写成先 `git status` 再选句子。

- [Trade-off] `SKILL.md` 不放完整回执，只读主文档的 agent 可能仍临场汇报。  
  Mitigation: 主文档补「成功后按对应 guide 的回执样例」；提交细节本就会读 guide。

## Migration Plan

1. 改 `SKILL.md`：条目标题一句、该次回复不 push / 随后可 push、成功回执指向 guide。
2. 改 single/batch 模板、编号规则、确认表、成功回执样例。
3. 改 troubleshooting：失败禁止套成功回执。
4. CHANGELOG 记录预览标题与回执；不改已发布的 `1.0.0` / `2.0.0` 条目正文。
5. 回滚即还原上述 markdown。
