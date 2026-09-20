## 1. 默认加载层

- [x] 1.1 在 `skills/mxcat-commit/SKILL.md` 预览门禁写明：每条预览用 `## commit N`，编号是身份、丢掉后不滑动；不要再用 `待确认 · 1/N`
- [x] 1.2 把「只批准提交则不 push」收窄为该次回复；写明提交成功后用户再说 push 可以推一次；成功回执按对应 guide 样例，不要临场改结构

## 2. Single 预览与回执

- [x] 2.1 将 `references/single-commit.md` 预览卡标题改为 `## commit 1`，去掉 `待确认 · 1/1`
- [x] 2.2 在确认表加入：提交成功后的「帮我 push / 推一下 / git push」允许一次 `git push`（无 force、无擅自 `-u`）
- [x] 2.3 在提交成功后加入只提交回执样例（「提交已完成。」+ Commit/标题/变更 + 先 `git status` 再写工作区句 + 有 origin 则邀 push）；「提交并 push」成功用合成回执；之后再 push 用「已推送到 GitHub。」（无 Commit 块）；非 GitHub 改「远程」

## 3. Batch 预览、编号与回执

- [x] 3.1 将 `references/batch-commit.md` 预览模板改为 `## commit 1`、`## commit 2`；「只有一组」改为仍写 `## commit 1`，不要 `1/1`
- [x] 3.2 在第 4 节写明：丢掉后保留原号（示例 1 与 3）；合并吃较小号；拆开时原号留第一条、新条用 max+1；认 `commit N` 不认滑动下标
- [x] 3.3 确认表加入提交成功后再 push；整单成功后放与 single 同一结构的三套回执样例，其中合成回执演示 Commit 块一条、分支行两条 hash

## 4. 故障说明与变更记录

- [x] 4.1 在 `references/troubleshooting.md` 写明：中途失败、无上游、push 失败不要用成功回执开头；commit 成功但 push 失败可用「提交已完成」回执再另段说明未推送
- [x] 4.2 用 changelog-content-writer 技能更新 `skills/mxcat-commit/CHANGELOG.md`：记录 `## commit N`、稳定编号、三套成功回执、提交后再 push；不改写已发布的 `1.0.0` / `2.0.0` 条目正文
- [x] 4.3 通读 SKILL.md 与两份 guide：确认固定收尾原文未改；预览标题已无 `待确认 ·` / `1/N`；三套回执结构一致
