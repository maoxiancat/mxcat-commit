## 1. Single 提交锁路径

- [x] 1.1 改 `references/single-commit.md` 第 5 步：默认整棵工作树先 `git add --` 该条预览路径，再 `git commit --file <msg> --only --` 同一份路径；样例显式写 `--only --`
- [x] 1.2 在同一节写明：锁路径 = 该条预览「改动部分」的仓库相对路径；rename / delete 要包含旧路径与新路径；用户只要暂存区则不要 add；这些路径上 `git diff` 非空则停止，不要 `--only` 把 unstaged hunk 带进去

## 2. Batch 提交锁路径

- [x] 2.1 改 `references/batch-commit.md` 第 2 步与第 5 步：把「记下将 git add 的路径」改为「记下将进入这条 commit 的路径」；按序提交的样例与 single 相同（`git add --` + `git commit --file --only --`）
- [x] 2.2 写明丢掉的条目即使仍 staged 也不列入剩余条的 `--only`；只要暂存区的混合文件护栏与 single 一致

## 3. 自检与故障说明

- [x] 3.1 在 `references/single-commit.md` 第 6 步增加 `git show --name-only`（rename 用 `--name-status`）对照该条预览路径；对不上按自检失败停止。batch 继续写「做与 single 相同的自检」
- [x] 3.2 在 `references/troubleshooting.md` 增加「自检失败：文件集合与预览不一致」：报告实际路径与预览路径，停止后续条，不 push，不用成功回执，不自动 reset
- [x] 3.3 用 changelog-content-writer 技能更新 `skills/mxcat-commit/CHANGELOG.md`：记录提交锁预览路径与文件集合自检；不改写已发布版本条目正文
