## 1. 回执样例改成列表

- [x] 1.1 改 `SKILL.md` 预览门禁那句：组内写成 Markdown 无序列表，不要 `<br>`、行末两空格或行末反斜杠；开头句与工作区句仍是段落
- [x] 1.2 改 `references/single-commit.md` 第 7 步说明与三套围栏样例：`Commit：` / `标题：` / `变更：` 与 `分支：` / `仓库地址：` 组内每项 `- ` 起头，去掉 `<br>`
- [x] 1.3 改 `references/batch-commit.md` 第 7 步说明与样例：与 single 相同；多条新建时重复 Commit 列表组，组间空一行

## 2. 故障说明与 changelog

- [x] 2.1 改 `references/troubleshooting.md`：push 失败可用「提交已完成」回执时，把「字段组内用 `<br>` 换行」改成列表
- [x] 2.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`：记录成功回执字段组改用 Markdown 列表；不改写已发布版本条目正文（含 1.1.0 里提到 `<br>` 的历史句）
- [x] 2.3 通读 SKILL.md 与两份 guide、troubleshooting：技能正文里成功回执不再出现 `<br>`；正式样例未改成代码块；固定收尾原文未改
