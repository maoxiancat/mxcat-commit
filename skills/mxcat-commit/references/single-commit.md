# Single Commit 详细流程

仅当用户明确要求「合为一个 commit」（或「合成一条」「不要拆」「就提交一条」）时读取本文。默认分批流程见 `batch-commit.md`。

确认前禁止 `git commit`。该次回复只批准提交、未要求 push 时，不要运行 `git push`。提交成功后用户再说「帮我 push」「推一下」或 `git push`，可以对当前上游再推一次。

## 1. 确认当前确实是 single

```bash
git status --short
```

- 用户必须已经明确要求合成一条 commit。
- 若用户只说「帮我提交」而没有说合为一条，改走 `batch-commit.md`。
- 输入默认是整棵未提交工作树（staged + unstaged + untracked）。
- 仅当用户同时要求「只提交暂存区」时，输入才收缩为 staged；此时不要纳入未暂存/未跟踪文件。
- 若收缩为 staged 后暂存区为空，停止并说明。

## 2. 分析当前输入范围内的变更

```bash
git status
git diff
git diff --cached
git diff --cached --stat
```

只提交暂存区时，用 `git diff --cached` 即可。要合成整棵工作树时，还要看 unstaged / untracked。

根据实际 diff 写消息，不要先写标题再反推改动。

未声明时，subject 与 body 用简体中文。用户本轮明确要求英文时再覆盖。标题必须带 `(scope)`，规范真源是 `commit-convention.md`。

## 3. 出示预览卡（此时不要提交）

对这一条拟提交变更输出：

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

尚未提交 commit 和 push，请回复「提交」「提交并 push」等进行提交、push，也可以合并 commit 或不要提交某个 commit
```

解释必须覆盖这三项：

1. 为何这个 emoji
2. 为何这个 scope
3. **改动了哪些部分**（模块、关键文件或行为；列出将进入这条 commit 的范围）

点到文件/模块/行为即可，不要逐行复述 diff。预览卡之后必须另起一段，**原样**输出上面那句收尾（不得改字；不要写进「解释」）。单条仍用 `## commit 1`，不要写成 `待确认 · 1/1`。

尚未出示这张预览时，「帮我提交」「合为一个 commit」只用来进入流程，不是确认。

## 4. 等待确认或改稿

| 用户说的 | 动作 |
|---|---|
| 「提交」「确认提交」「帮我提交」 | 按预览执行第 5 步，不要 `git push` |
| 「提交并 push」 | 按预览执行第 5 步；commit 与自检都成功后再一次 `git push` |
| 提交已成功后说「帮我 push」「推一下」或 `git push` | 对当前上游一次 `git push`；不要 `--force`；没有上游则报告且不要 `push -u`；成功后用第 7 步 push 回执 |
| 改 emoji / scope / 标题 / 正文 | 更新预览卡（含固定收尾），仍然不提交 |
| 「不要提交」这条 / 不要提交某个 commit | 停止并说明没有待提交项；文件留在工作区；不要 `git restore` / `checkout` / `reset` |
| 「拆开」「还是分批」 | 改读 `batch-commit.md`，不在这里提交 |
| 「合为一条」 | 已在 single 时继续本预览；不要当成跳过预览 |
| 强调「不需要预览」「跳过预览」「不要预览」 | 可跳过预览，直接第 5 步；消息仍须遵守 `commit-convention.md` |
| 「直接提交」或只给了标题，但没强调不需要预览 | 仍出示预览与固定收尾，不提交 |

## 5. 确认后执行提交

推荐 `printf` + `--file`，避免空行丢失。不要写入 `AI-Co-Authored-By:`、`Co-authored-by:`、`Jira-Refs:`。

先把预览中列出的路径纳入 index（整棵工作树合成一条时需要 `git add`；若用户只要暂存区，则不要 add 未暂存文件）：

```bash
git add path/to/EmptyState.tsx path/to/ExportButton.tsx
```

然后提交：

```bash
printf '%s\n' \
':sparkles: (charts) 增加空数据占位' \
'' \
'- 折线图无数据时展示占位图' \
'- 导出入口改为禁用而不是报错' > /tmp/commit_msg.txt

git commit --file /tmp/commit_msg.txt
```

若有 `BREAKING CHANGE:`，标题用 `:emoji: (scope) ! subject`，body 与 footer 之间留一个空行：

```bash
printf '%s\n' \
':bug: (charts) ! 拒绝重复导出' \
'' \
'- 重复导出请求改为立即失败' \
'' \
'BREAKING CHANGE: 重复导出现在会直接报错' > /tmp/commit_msg.txt

git commit --file /tmp/commit_msg.txt
```

Body 含反引号时尤其不要改用多个 `-m`。

若用户批准的是「提交并 push」，先做第 6 步自检，通过后再对当前分支上游执行一次 `git push`。不要 `--force` 或 `--force-with-lease`。没有上游则报告原因并停止，不要 `git push -u`。该次回复只批准「提交」时不要 push。提交成功后用户再说「帮我 push」「推一下」或 `git push`，自检已通过且有上游时再一次 `git push`。自检失败则不要 push。

## 6. 提交后自检

校验 header（shortcode + **必写** scope）：

```bash
git log -1 --pretty=%B | head -n 1 | grep -Eq '^:[a-z0-9_+-]+: \([^)]+\)( !)? .+'
```

检查空行：

```bash
git cat-file -p HEAD | sed -n '/^$/,$p' | sed -n '2,120p' | cat -vet
```

确认没有禁止的页脚：

```bash
git log -1 --pretty=%B | grep -Ei '^(AI-Co-Authored-By:|Co-authored-by:|Co-Authored-By:|Jira-Refs:)' && echo FAIL || echo OK
```

再看 subject / body 是否仍是本次语言（默认中文）。不要在未确认时 `git commit --amend`。

自检失败则停止并报告，不要输出第 7 步成功回执；恢复动作见 `troubleshooting.md`。自检通过后输出第 7 步回执。

## 7. 成功回执

回执是带槽位的样例，不要改结构。先 `git status --short`：工作区不干净就不要写「应已无未提交变更」，改为说明还剩什么。短 hash 与标题用 `git log`；文件数与 ± 行用 `git show --stat`（只有插入写成 `+N 行`，有删除写成 `+A / -B 行`）。括号里点到模块/产物即可。origin 主机是 `github.com`（含 SSH）时用「GitHub」，否则把开头里的 GitHub 改成「远程」。SSH origin 转成 https 网页地址再写 `仓库地址：`；推不出来就省略该行。`Commit：` 块只列本次新建的 commit；分支行「含 … 提交」列这次 `git push` 实际送出的短 hash（可能含更早未推送的）。失败不要用这些开头。

`Commit：` / `标题：` / `变更：`，以及 `分支：` / `仓库地址：`，同一组里不要空行。除最后一项外，每行末尾写 `<br>`，否则聊天 Markdown 会把相邻行折成一段。组与组之间（例如 Commit 块和「当前工作区」、工作区句和 push 信息块）仍空一行。不要写 `远程：`。

只提交成功（该次未 push）：

```markdown
提交已完成。

Commit： a1b2c3d<br>
标题： :sparkles: (charts) 增加空数据占位<br>
变更： 2 个文件，+40 行（空数据占位与导出禁用）

当前工作区应已无未提交变更。若要推到 owner/repo，可以说一声我帮你执行 git push。
```

没有 origin 时去掉最后一句邀 push。

「提交并 push」都成功：

```markdown
已提交并推送到 GitHub。

Commit： a1b2c3d<br>
标题： :sparkles: (charts) 增加空数据占位<br>
变更： 2 个文件，+40 行（空数据占位与导出禁用）

当前工作区应已无未提交变更

分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）<br>
仓库地址：https://github.com/owner/repo
```

上面 `Commit：` 只有本次新建的 `a1b2c3d`；分支行可以同时列出更早未推送的 `d0e8902`。不要再邀请用户 push。

提交成功之后再 push 成功：

```markdown
已推送到 GitHub。

分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）<br>
仓库地址：https://github.com/owner/repo
```

不要再列出 `Commit：` 块。
