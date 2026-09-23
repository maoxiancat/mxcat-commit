## 1. 默认加载层与收尾

- [x] 1.1 改 `SKILL.md` 预览门禁：预览后确认改为独立的「提交」；写上「提交吧」「好的，提交吧」「可以提交」算批准；单独的「确认」「可以」「好的」「行」「ok」「lgtm」「就这样」以及疑问句不算
- [x] 1.2 同一节补子集：点名只提交某几条当场做；只丢掉则重出再等；改字与提交同一句则按新稿提交；拆开/合并/合为一条即使带「提交」也先重出
- [x] 1.3 三处固定收尾改成同一句原文：尚未提交。回复「提交」或「提交并 push」。`SKILL.md` 规定句、`references/single-commit.md` 与 `references/batch-commit.md` 预览模板各一处，不得改字

## 2. 确认表

- [x] 2.1 改 `references/single-commit.md` 第 4 步表：与 `SKILL.md` 同一套独立「提交」、软附和/疑问不算、改字同句提交、拆合仍重出；单条下「只提交 commit 1」等于批准该条
- [x] 2.2 改 `references/batch-commit.md` 第 4 步表：加上「只提交 commit 1」「提交 1 和 3，2 先留着」当场做；「不要提交 commit 2」仍重出；「不要 2，其余提交」当场做剩余；认不清「第二条」就问。两边表意同字，不要各写一套同义词

## 3. 故障说明与 changelog

- [x] 3.1 检查 `references/troubleshooting.md`：旧长收尾或把「可以提交」写进否定名单的句子改成新原文与新判定；丢掉后无剩余项的说明保留
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`：记录独立「提交」、子集当场做、改字同句可提交、收尾缩短，以及「可以提交」预览后重新算批准；不改写已发布版本条目正文
