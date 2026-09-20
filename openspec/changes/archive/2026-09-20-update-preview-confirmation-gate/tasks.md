## 1. 默认加载层预览门禁

- [x] 1.1 改写 `skills/mxcat-commit/SKILL.md`「预览门禁」：按本轮是否已出预览分阶段；未出预览时「提交」「帮我提交」「commit」等只出预览；已出预览后「提交」「确认提交」「帮我提交」批准 commit，「提交并 push」批准 commit 且随后一次 push
- [x] 1.2 在同一节写入固定收尾原文（与 preview-gate spec 一字不差），并写明预览卡之后必须原样输出、不得改写
- [x] 1.3 替换跳过条件：删除「完整标题 + 直接提交」；改为仅当用户强调不需要预览（不需要预览 / 跳过预览 / 不要预览）才可跳过；删除 lgtm / 就这样 作为规范确认词

## 2. Single 预览与确认

- [x] 2.1 更新 `references/single-commit.md` 预览卡模板：在卡后另起一段输出固定收尾原文
- [x] 2.2 重写第 4 节确认表，与 SKILL.md 阶段规则一致（提交 / 确认提交 / 帮我提交 / 提交并 push / 改稿重出 / 合为一条仍走预览 / 仅强调不需要预览才跳过）
- [x] 2.3 在确认后步骤加入：仅「提交并 push」且 commit 成功后才一次 `git push`；无 `--force`；无上游则报告且不 `push -u`

## 3. Batch 预览、丢掉条目与 push

- [x] 3.1 更新 `references/batch-commit.md` 整单预览模板：全部条目之后另起一段输出同一句固定收尾
- [x] 3.2 重写第 4 节确认表：对齐阶段确认；「不要提交第 N 条」从预览移除、文件留工作区、禁止 restore/checkout/reset、重出剩余预览与收尾；0 条则停止
- [x] 3.3 在按序提交后写明：用户只说提交则不 push；「提交并 push」须全部 commit 成功后再恰好一次 `git push`；中途失败不 push、不 force

## 4. 故障说明与变更记录

- [x] 4.1 在 `references/troubleshooting.md` 补充：无上游时如何报告且不擅自 `-u`/`--force`；丢掉全部预览条目后停止、文件仍留工作区
- [x] 4.2 用 changelog-content-writer 技能更新 `skills/mxcat-commit/CHANGELOG.md`：记录确认词、固定收尾、可选 push、丢掉条目与新跳过条件；不改写已发布的 `1.0.0` 条目正文
- [x] 4.3 通读 SKILL.md 与两份 guide，确认收尾原文三处完全一致，且「合为一条」仍被写成改路由并重出预览、不是跳过门禁
