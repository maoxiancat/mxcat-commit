## 1. validate

- [x] 1.1 添加可执行的 `skills/mxcat-commit/scripts/validate`：只读标准输入，不创建 commit，不读固定路径。header 匹配 `^:[a-z0-9_+-]+: \([^)\s]+\)( !)? .+`；第一行之后还有非空行时，标题段之后必须还有正文；只有标题通过；多一个空行或 body 与 `BREAKING CHANGE:` 之间缺空行不因此失败；拒绝行首 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:`、`Jira-Refs:`

## 2. commit_one

- [x] 2.1 添加可执行的 `skills/mxcat-commit/scripts/commit_one`：用法 `commit_one [--add] -- <路径…>`。把本次标准输入收进 `mktemp` 临时文件，退出时删除；先交给 `validate`，失败则不 `git commit`
- [x] 2.2 通过后执行 `git commit --only --` 这些路径，消息来自该临时文件。`--add` 时先 `git add --` 同一份路径；不传 `--add` 且这些路径 `git diff` 非空时，在提交前非 0 退出。不按文件名拒绝路径
- [x] 2.3 提交成功后用 `git show` 对照参数路径（rename 用 `--name-status`）。不一致则非 0 退出，不 `reset`

## 3. 测试

- [x] 3.1 在 `skills/mxcat-commit/tests/` 覆盖：合法消息 `validate` 为 0；缺空行、坏 header、禁页脚时 `commit_one` 不创建 commit
- [x] 3.2 用临时仓库覆盖：两条都已暂存时只提交其中一条，另一条仍留在 index；不传 `--add` 且路径仍有未暂存改动时不创建 commit；参数含 `.env` 且消息合法时该路径进入 commit

## 4. 文档

- [x] 4.1 改 `references/single-commit.md` 与 `references/batch-commit.md` 第 5 步样例为 `printf | scripts/commit_one --add -- <路径>`，batch 每条各自一条管道。第 6 步改为入口非 0 即停，不再让 agent 另跑四段 grep
- [x] 4.2 改 `references/troubleshooting.md` 的自检失败说明：入口拒绝或路径对照失败；写明不要绕过脚本另写 `git commit`，也不要写 `/tmp/commit_msg.txt`
- [x] 4.3 `SKILL.md` 用一句话指向 `scripts/commit_one`，不展开命令。用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
