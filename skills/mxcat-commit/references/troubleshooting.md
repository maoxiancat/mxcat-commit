# Troubleshooting

仅在自检失败、hook 失败、消息空行不对、文件集合与预览不一致、push 无上游或 push 失败、或丢掉预览后没有剩余条目时读取本文。不要把排查步骤提前写进 `SKILL.md`。

sh、bash、zsh 的入口是 `scripts/commit_one`。Windows PowerShell 的入口是 `scripts/commit_one.ps1`。下文的 `commit_one` 指当前环境的那一个。

不要自动 `git reset` 已经成功的 batch 条目。仅当用户明确要求撤回已成功的 commit 时，才允许 `git reset --soft`；不要从常规流程抄过来。不要补写或「修好」`AI-Co-Authored-By:`。用户不要提交某一预览条目时，不要对这些文件 `git restore` / `checkout` / `reset`。中途失败、无上游、push 失败时，不要用「提交已完成。」「已提交并推送到 GitHub。」或「已推送到 GitHub。」开头。

## 未预览就 commit 或 push

用户首句说「提交并 push」却被直接提交时，属于违反预览门禁（收尾里的「提交并 push」只适用于**已出预览之后**的确认）。

1. 向用户说明应先看到预览再确认；若 commit 消息不符合预期，见下文撤回单条。
2. 若需撤销误提交：仅当用户明确要求时，`git reset --soft HEAD~1`（batch 多条则按条数协商），然后回到对应 guide **重出预览与固定收尾**，不要再次跳过预览。
3. 若已误 push：不要 force push；与用户确认是否 revert 或保留远程，再按 guide 重走预览。

## 自检失败：标题不合规

`commit_one` 因 header 不合格退出时，该条 commit 还没创建。header 对不上 `:emoji: (scope) subject`（或缺 `(scope)`、括号内空白、并列 scope 如 `(auth,api)`、括号内不是单个小写 token、写成 Unicode emoji、写成 `feat(scope):`）都属于这类。

- 停止后续提交。
- 向用户报告脚本错误。
- 不要绕过 `scripts/commit_one` 另写 `git commit`。
- 不要把消息写到固定路径（包括 `/tmp/commit_msg.txt`）。
- 不要 `git reset`：这次没有新 commit。
- 回到对应 guide，按已确认预览重跑 `commit_one`。

## 自检失败：空行丢失

标题后还有正文，但标题与正文粘在一起、中间没有空行时，`commit_one` 会在创建 commit 之前退出。后面另有空行（例如 `BREAKING CHANGE:` 之前）也不能把这次粘连洗白。多一个空行，或 body 与 `BREAKING CHANGE:` 之间缺空行，不会仅因此被拒绝。生成时 header 与 body 之间、body 与 `BREAKING CHANGE:` 之间仍要恰好一个空行。

处理：

1. 停止后续提交，报告脚本错误。
2. 不要 `git reset`：这次没有新 commit。
3. 回到对应 guide，用 `printf` 管道到 `scripts/commit_one` 重跑。不要把消息写到固定路径（包括 `/tmp/commit_msg.txt`）。不要绕过脚本另写 `git commit`。Body 含反引号时尤其不要改用多个 `-m`。

## 自检失败：文件集合与预览不一致

目录参数，或参数里夹了相对 `HEAD` 没有差异、因而不会进入这次 commit 的路径时，`commit_one` 在 `git commit` 之前退出。夹了被忽略的文件、或 `git add` 本身失败时同样如此。这条 commit 还没创建，index 与调用前一致：

- 停止后续提交。
- 向用户报告脚本错误。
- 不要 `git reset`：这次没有新 commit，index 也已放回调用前。
- 不要绕过 `scripts/commit_one` 另写 `git commit`，也不要把消息写到 `/tmp/commit_msg.txt`。
- 改成这次真正有差异的文件路径后，回到对应 guide 重跑。

`./` 前缀，或在非仓库根目录传入相对当前目录的路径，收成同一仓库相对路径后，对照可以通过。

提交已经成功，但规范化之后文件集合仍对不上时，该条 commit 已经存在，脚本不会 reset，index 保持这次提交留下的内容：

- 停止后续提交。
- 向用户报告脚本打印的参数路径与实际路径。
- **不要**运行 `git push`。
- **不要**用成功回执开头。
- 不要自动 reset。已成功的 commit 保留。
- 不要在未确认时 `git commit --amend`。
- 不要绕过 `scripts/commit_one` 另写 `git commit`，也不要把消息写到 `/tmp/commit_msg.txt`。
- 仅当用户明确要求撤回这一条时，才执行 `git reset --soft HEAD~1`，然后回到对应 guide 重出预览。

常见原因是路径参数和该条预览「改动部分」不一致。

## 部分提交失败

同一文件按 hunk 提交时，补丁对不上当前 diff、路径是二进制、是 rename / copy 同时还要拆内容，或路径尚未进入 HEAD，`commit_one` 在创建 commit 之前退出。工作区应仍是调用前的内容：

- 停止后续提交，报告脚本错误。
- 不要改成不带 `--hunks` 的整文件提交。
- 不要 `git reset`：这次没有新 commit。
- 不要把补丁或消息写到 `/tmp/commit_msg.txt`。

同一路径在补丁里出现多次 `diff --git`、暂存的是符号链接或可执行位、工作区类型和 index 不一致时，提交后工作区仍应是调用前的路径。历史里的类型和模式与要提交的条目一致。模式或类型对不上时，这条 commit 已经存在，脚本不会 reset。工作区应已恢复为调用前的内容。

提交已经成功，但该文件的 diff 对不上这次指定的 hunk 时，这条 commit 已经存在，脚本不会 reset。工作区应已恢复为调用前的内容：

- 停止后续提交。
- **不要**运行 `git push`。
- **不要**用成功回执开头。
- 不要自动 reset。已成功的 commit 保留。
- 仅当用户明确要求撤回这一条时，才执行 `git reset --soft HEAD~1`，然后回到对应 guide 重出预览。

## 自检失败：出现禁止页脚

`commit_one` 因 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:` 或 `Jira-Refs:` 退出时，该条 commit 还没创建。行首有空格或制表符也同样拒绝：

- 停止并报告这些行。
- **不要**改成补上一行 AI trailer。
- 不要 `git reset`，不要绕过脚本另写 `git commit`，不要把消息写到 `/tmp/commit_msg.txt`。
- 回到对应 guide，去掉这些行后重跑 `commit_one`。

若 hook / IDE 在提交时额外注入了别的 trailer（例如 `Made-with:`），commit 已经存在。同样先报告，问用户是否保留；未确认不要改历史。用户确认后，才 `git reset --soft HEAD~1`，再经 `commit_one` 重写。

## Hook 或 lint-staged 失败

`commit_one` 因 hook 失败时，这条 commit 还没创建，index 与调用前一致：

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
- 已成功的 commit 保留。可用「提交已完成。」回执（字段组内写成 Markdown 列表、不要空行；可邀 push），再另段说明没有推上去。

batch 中途某条 commit 或自检失败时，同样不要 push，也不要用成功回执开头。

## 丢掉预览条目后没有剩余项

用户不要提交某一预览条目时：

- 只从预览计划里拿掉该条，对应文件留在工作区。
- **不要**对这些文件运行 `git restore`、`git checkout` 或 `git reset`。
- 还有剩余条目：整单重出（含固定收尾），再等确认；同一次回复里不要提交。同一句还批准剩余条目时，按对应 guide 第 4 步当场提交剩余条，不要走「重出再等」。
- 没有剩余条目：停止并说明没有待提交项，不要创建 commit，也不要 push。
