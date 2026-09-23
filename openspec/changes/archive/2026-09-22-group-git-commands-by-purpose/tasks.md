## 1. 两份 guide 顶部改成分族列表

- [x] 1.1 改 `references/batch-commit.md` 开头：用 `design.md` 那份三族列表替换「只用 `git status`、`git diff`、`git add`、`git commit`」整句；保留后面确认前禁止 `git commit` / 未要求则不 push
- [x] 1.2 把同一份列表写入 `references/single-commit.md` 顶部，放在确认前禁止那句之前；两边同字，不要各写一套

## 2. 恢复通道与 changelog

- [x] 2.1 改 `references/troubleshooting.md` 开头：补一句仅当用户明确要求撤回已成功 commit 时才允许 `git reset --soft`；保留「不要自动 reset」
- [x] 2.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`：记录 git 命令改按用途分族授权；不改写已发布版本条目正文
- [x] 2.3 通读 SKILL.md 与两份 guide：`SKILL.md` 未展开命令表；技能正文不再出现封闭四件套「只用」；`--only`、预览确认词、固定收尾、回执结构未改
