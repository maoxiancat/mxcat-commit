# Batch Commit 详细流程

默认读取本文。仅当用户明确要求「合为一个 commit」（或「合成一条」「不要拆」「就提交一条」）时改走 `single-commit.md`。

只用 `git status`、`git diff`、`git add`、`git commit`。仅当用户在预览后批准「提交并 push」且全部预定 commit 成功，或预定 commit 已成功之后用户明确要求 push 时，才额外使用一次 `git push`。

确认整单之前禁止 `git commit`。该次回复只批准提交、未要求 push 时，不要运行 `git push`。

## 1. 确认输入范围

```bash
git status --short
```

- 默认输入是整棵未提交工作树：staged + unstaged + untracked。
- 用户明确要求「只提交暂存区」、且没说合为一条时，仍走本文，但只用 staged。
- 用户要求合为一条时，改读 `single-commit.md`，不要在这里拆批。
- 若输入范围内没有任何变更，停止并说明。

## 2. 分析变更并按逻辑分组

```bash
git status
git diff
git diff --cached
git diff --stat
```

按语义拆成多条 commit，例如同一模块/同一意图放一起，无关改动拆开。每条都必须能独立构成合法消息（必写 `(scope)`、默认中文）。不要先写标题再反推 diff。

每条 commit 记下将 `git add` 的路径。不要把预览里没列出的文件塞进某条。

若逻辑上只有一组，预览写成 `## commit 1`，仍走本文，不要改成 single。

## 3. 一次出示整单预览（此时不要提交）

按顺序输出全部条目：

```markdown
## commit 1

标题
:sparkles: (charts) 增加空数据占位

正文
- 折线图无数据时展示占位图
- 导出入口改为禁用而不是报错

解释
- :sparkles: 因为这是新的空数据展示，不是修崩溃
- scope 用 charts，改动都在图表模块
- 改动部分：`EmptyState.tsx` 新增占位图；`ExportButton` 在无数据时改为 disabled

## commit 2

标题
:wrench: (charts) 调整空数据文案配置

正文
- 占位文案改为可配置

解释
- :wrench: 因为这是配置，不是新功能
- scope 仍用 charts
- 改动部分：`charts.config.ts` 增加 emptyState 文案字段

尚未提交 commit 和 push，请回复「提交」「提交并 push」等进行提交、push，也可以合并 commit 或不要提交某个 commit
```

每条解释必须覆盖：为何这个 emoji、为何这个 scope、**改动了哪些部分**。点到文件/模块/行为即可，不要逐行复述 diff。全部条目之后必须另起一段，**原样**输出上面那句收尾（不得改字；不要写进某条的「解释」）。条目标题用 `## commit N`，不要写成 `待确认 · 1/N`。

尚未出示这张整单预览时，「帮我提交」「按逻辑分批提交」只用来进入流程，不是确认。

## 4. 等待整单确认或改稿

改稿时认标题上的 `commit N`，不要把「第二条」当成当前列表下标（丢掉 2 后，列表上第二张是 `commit 3`）。

丢掉某条后剩余条目保留原号：原 `## commit 1` / `## commit 2` / `## commit 3` 丢掉 2 后，重出 `## commit 1` 与 `## commit 3`，不要填补空号。

合并两条时，留下较小号（1 和 3 合并后还叫 `## commit 1`，3 消失）。

拆开某条时，原号留给拆出的第一条；新条用本计划曾经用过的最大编号 + 1（含已丢掉或已合并消失的号）。例如曾分配 1、2、3 且 2 已丢掉，把 commit 3 拆成两条 → `## commit 3` 与 `## commit 4`。

| 用户说的 | 动作 |
|---|---|
| 「提交」「确认提交」「帮我提交」 | 按预览顺序执行第 5 步，不要 `git push` |
| 「提交并 push」 | 按预览顺序执行第 5 步；全部 commit 与自检都成功后再一次 `git push` |
| 提交已成功后说「帮我 push」「推一下」或 `git push` | 对当前上游一次 `git push`；不要 `--force`；没有上游则报告且不要 `push -u`；成功后用第 7 步 push 回执 |
| 改某条 emoji / scope / 标题 / 正文 | 更新整单预览（含固定收尾），仍然不提交 |
| 「把 commit 1 和 commit 3 合并」「把 commit 2 拆开」 | 按上面编号规则重出整单预览（含固定收尾），仍然不提交 |
| 「不要提交 commit N」 / 不要提交某个 commit | 从预览移除该条；对应文件留在工作区；不要对这些文件 `git restore` / `checkout` / `reset`；重出剩余整单与固定收尾（保留原号，例如丢掉 2 后仍是 1 与 3），仍然不提交。若已无剩余条目，停止并说明没有待提交项 |
| 「合为一条」 | 改读 `single-commit.md`，重出 single 预览，不在这里提交，也不算跳过预览 |
| 强调「不需要预览」「跳过预览」「不要预览」 | 可跳过预览，直接第 5 步；消息仍须遵守 `commit-convention.md` |
| 「直接提交」或只给了标题，但没强调不需要预览 | 仍出示整单预览与固定收尾，不提交 |

## 5. 确认后按序提交

对预览中的每一条，按顺序：

1. `git add` 该条列出的路径（只要暂存区时，不要 add 未暂存文件）。
2. `printf` + `git commit --file` 写入该条标题和正文。不要写入 `AI-Co-Authored-By:`、`Co-authored-by:`、`Jira-Refs:`。
3. 做与 `single-commit.md` 相同的 header / 空行 / 禁页脚自检。
4. 通过后再处理下一条。

```bash
git add path/to/EmptyState.tsx path/to/ExportButton.tsx

printf '%s\n' \
':sparkles: (charts) 增加空数据占位' \
'' \
'- 折线图无数据时展示占位图' \
'- 导出入口改为禁用而不是报错' > /tmp/commit_msg.txt

git commit --file /tmp/commit_msg.txt
```

Body 含反引号时不要改用多个 `-m`。不要在未确认时 `git commit --amend`。该次回复只批准「提交」时，全部条目成功后也不要 `git push`。

若用户批准的是「提交并 push」：必须全部预定 commit 与自检都成功后，再对当前分支上游执行恰好一次 `git push`。不要在中间某条之后 push。不要 `--force` 或 `--force-with-lease`。没有上游则报告原因并停止，不要 `git push -u`。已成功的 commit 保留。提交成功后用户再说「帮我 push」「推一下」或 `git push`，有上游时再一次 `git push`。

全部预定条目与自检都成功后，输出第 7 步回执。

## 6. 中途失败则停止

任一条在 `git add`、`git commit`（含 hook）或自检失败时：

- **不要**继续创建后续预览中的 commit。
- **不要**假装整单已完成。
- **不要**运行 `git push`。
- **不要**用第 7 步成功回执开头。
- 向用户报告：哪些条目已成功、哪一条失败（含错误摘要）、哪些尚未尝试。
- 已成功的条目保留；不要自动 `reset` 掉它们。是否回滚由用户决定，恢复动作见 `troubleshooting.md`。

## 7. 成功回执

结构与 `single-commit.md` 第 7 步相同。多条新建 commit 时，按提交顺序重复 `Commit：` / `标题：` / `变更：`（组内不要空行，除最后一项外行末写 `<br>`）。先 `git status --short` 再决定是否写「应已无未提交变更」。origin 不是 GitHub 时，把开头里的 GitHub 改成「远程」。`远程：` / `分支：` / `仓库地址：` 同样组内不要空行，用 `<br>` 换行。

只提交成功（该次未 push）；多条则重复 Commit 块：

```markdown
提交已完成。

Commit： a1b2c3d<br>
标题： :sparkles: (charts) 增加空数据占位<br>
变更： 2 个文件，+40 行（空数据占位与导出禁用）

Commit： b2c3d4e<br>
标题： :wrench: (charts) 调整空数据文案配置<br>
变更： 1 个文件，+8 行（emptyState 文案配置）

当前工作区应已无未提交变更。若要推到 owner/repo，可以说一声我帮你执行 git push。
```

「提交并 push」都成功。下面演示本次只新建一条，但这次 push 还送出了更早未推送的 commit：`Commit：` 块只有新的那条，分支行列出实际送出的两条 hash。

```markdown
已提交并推送到 GitHub。

Commit： a1b2c3d<br>
标题： :sparkles: (charts) 增加空数据占位<br>
变更： 2 个文件，+40 行（空数据占位与导出禁用）

当前工作区应已无未提交变更

远程： https://github.com/owner/repo.git<br>
分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）<br>
仓库地址：https://github.com/owner/repo
```

提交成功之后再 push 成功：

```markdown
已推送到 GitHub。

远程： https://github.com/owner/repo.git<br>
分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）<br>
仓库地址：https://github.com/owner/repo
```

不要再列出 `Commit：` 块。
