## 1. single 样例

- [x] 1.1 改 `references/single-commit.md` 第 5 步两处样例（普通 body 与 `BREAKING CHANGE:`）：`printf '%s\n'` 管道到 `git commit --file - --only --`，保留显式 `''`，删掉 `/tmp/commit_msg.txt`。`git add` 仍在管道之前。不要改成多个 `-m`

## 2. batch 样例

- [x] 2.1 改 `references/batch-commit.md` 第 5 步样例为同一管道，并写明每条 commit 各自一条管道，不要复用上一条的消息来源

## 3. 故障说明

- [x] 3.1 在 `references/troubleshooting.md`「自检失败：空行丢失」重写消息那一步补一句：不要把消息写到固定路径（包括 `/tmp/commit_msg.txt`）。不要新开一节，不要改生成规则

## 4. Changelog

- [x] 4.1 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`：记录提交消息改为从本次命令的标准输入读入，不再使用固定临时路径；不改写已发布版本条目正文
