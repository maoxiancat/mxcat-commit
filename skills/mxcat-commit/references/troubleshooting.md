# Troubleshooting

仅在自检失败、hook 失败、消息空行不对、push 无上游或 push 失败、或丢掉预览后没有剩余条目时读取本文。不要把排查步骤提前写进 `SKILL.md`。

不要自动 `git reset` 已经成功的 batch 条目。不要补写或「修好」`AI-Co-Authored-By:`。用户不要提交某一预览条目时，不要对这些文件 `git restore` / `checkout` / `reset`。中途失败、无上游、push 失败时，不要用「提交已完成。」「已提交并推送到 GitHub。」或「已推送到 GitHub。」开头。

## 未预览就 commit 或 push

用户首句说「提交并 push」却被直接提交时，属于违反预览门禁（收尾里的「提交并 push」只适用于**已出预览之后**的确认）。

1. 向用户说明应先看到预览再确认；若 commit 消息不符合预期，见下文撤回单条。
2. 若需撤销误提交：仅当用户明确要求时，`git reset --soft HEAD~1`（batch 多条则按条数协商），然后回到对应 guide **重出预览与固定收尾**，不要再次跳过预览。
3. 若已误 push：不要 force push；与用户确认是否 revert 或保留远程，再按 guide 重走预览。

## 自检失败：标题不合规

提交后 header 对不上 `:emoji: (scope) subject`（或缺 `(scope)`、写成 Unicode emoji、写成 `feat(scope):`）时：

- 停止后续提交。
- 向用户报告失败项与 `git log -1 --pretty=%B` 的实际标题。
- 不要在未确认时 `git commit --amend`。
- 仅当用户明确要求撤回这一条时，才执行 `git reset --soft HEAD~1`，然后回到 `single-commit.md` 或 `batch-commit.md` 重出预览。

## 自检失败：空行丢失

header 与 body 之间、body 与 `BREAKING CHANGE:` 之间必须恰好一个空行。空行被吃掉时，多半是用了多个 `-m` 或未走 `printf` + `--file`。

处理：

1. 停止后续提交，报告哪一条空行不对。
2. 不要自动 reset。用户确认撤回这一条后，再用：

```bash
git reset --soft HEAD~1
```

3. 回到对应 guide，用 `printf` + `git commit --file` 按已确认预览重写消息。Body 含反引号时尤其不要改回多个 `-m`。

## 自检失败：出现禁止页脚

最终消息里出现 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:` 或 `Jira-Refs:` 时：

- 停止并报告这些行。
- **不要**改成补上一行 AI trailer。
- 用户确认后，才 amend 或 `git reset --soft HEAD~1` 去掉这些行，再按 `commit-convention.md` 重写。

若 hook / IDE 额外注入了别的 trailer（例如 `Made-with:`），同样先报告，问用户是否保留；未确认不要改历史。

## Hook 或 lint-staged 失败

`git commit` 因 hook 失败时：

- **不要**继续创建后续预览中的 commit。
- **不要**假装整单已完成。
- **不要**用成功回执开头。
- 报告：哪些条目已成功、哪一条失败（含错误摘要）、哪些尚未尝试。
- 已成功的条目保留，不要自动 reset。

不要假设每个仓库都有 `lint`、`prettier`、`stylelint` 或 `pnpm run commit`。先看真实配置：

1. `package.json` 里的 `scripts` 与 `lint-staged`
2. `.husky/pre-commit` 或仓库里的其他 Git hook

只运行仓库里确实存在的命令。hook 若改写了工作区：

- 停下来把实际 diff 告诉用户。
- 用户确认如何处理失败条之后，再更新预览；未确认不要提交下一条。

## 输入范围内没有变更

- 用户只要暂存区，而暂存区为空：停止并说明，不要擅自 `git add` 未暂存文件。
- 用户走默认 batch、整棵工作树也没有变更：停止并说明。

## Push 时没有上游或 push 失败

用户批准「提交并 push」，且全部预定 commit 已成功，但当前分支没有上游，或 `git push` 失败时：

- 向用户报告无法 push 的原因（例如没有 upstream）。
- **不要**运行 `git push -u`、`--force` 或 `--force-with-lease`。
- **不要**假装已经推送。
- **不要**用「已提交并推送到 GitHub。」或「已推送到 GitHub。」开头。
- 已成功的 commit 保留。可用「提交已完成。」回执（字段组内用 `<br>` 换行、不要空行；可邀 push），再另段说明没有推上去。

batch 中途某条 commit 或自检失败时，同样不要 push，也不要用成功回执开头。

## 丢掉预览条目后没有剩余项

用户不要提交某一预览条目时：

- 只从预览计划里拿掉该条，对应文件留在工作区。
- **不要**对这些文件运行 `git restore`、`git checkout` 或 `git reset`。
- 还有剩余条目：整单重出（含固定收尾），再等确认；同一次回复里不要提交。
- 没有剩余条目：停止并说明没有待提交项，不要创建 commit，也不要 push。
