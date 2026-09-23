# Single Commit 详细流程

仅当用户明确要求「合为一个 commit」（或「合成一条」「不要拆」「就提交一条」）时读取本文。默认分批流程见 `batch-commit.md`。

按用途使用 git，不要当成封闭四件套。

分析、自检、回执（只读，不改 index / HEAD / 工作区）：
- `git status`
- `git diff`（含 `--cached`）
- `git log`
- `git show`
- `git cat-file`
- `git remote get-url`
- 以及同等只读查询

写入（有门禁）：
- `git add --` 该条预览路径（默认整棵工作树；只要暂存区则不要 add）
- `git commit --file` + `--only --` 同一份路径（预览已确认）
- `git push`（仅预览后「提交并 push」且全部预定 commit 成功，或提交成功后再说 push；不要 `--force`，没有上游不要擅自 `-u`）

禁止：
- `--force` / `--force-with-lease`
- 擅自 `git push -u`
- 丢掉的预览文件 `git restore` / `checkout` / `reset`
- 自动 `git reset` 已成功的 batch 条目
- 未确认 `git commit --amend`
- 独立 index、shadow worktree、rebase、stash

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
git diff --numstat
git diff --cached --numstat
```

只提交暂存区时，用 `git diff --cached` 即可。要合成整棵工作树时，还要看 unstaged / untracked。

若路径明显是密钥、凭证或个人信息，且尚未进入 HEAD（未跟踪或 staged 新增），仍写进「改动部分」，预览里提醒；不要因为这类文件就停止或从预览拿掉。

本文是合为一条：`.agents/skills/*` 与 `git diff --numstat` 两列都是 `-` 的 binary 允许与业务写进同一条；该条含 binary 时解释须点名。

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
- 改动部分：`src/charts/EmptyState.tsx` 新增占位图；`src/charts/ExportButton.tsx` 在无数据时改为 disabled；`.env`

提醒
- `.env` 看起来是密钥/凭证。

尚未提交 commit 和 push，请回复「提交」「提交并 push」等进行提交、push，也可以合并 commit 或不要提交某个 commit
```

解释必须覆盖这三项：

1. 为何这个 emoji
2. 为何这个 scope
3. **改动了哪些部分**（模块、关键文件或行为；列出将进入这条 commit 的范围）

点到模块/文件/行为即可；列出的每个文件须用仓库相对路径写在反引号里（便于跳转到对应文件），需要定位改动行时可用 `` `startLine:endLine:path` `` 代码引用。不要只写裸文件名、不要逐行复述 diff。有尚未进入 HEAD 的密钥/个人信息时，这些路径仍写在「改动部分」；预览卡之后、固定收尾之前列出提醒（仓库相对路径、反引号），说明确认提交会写入历史。无此类路径则不要该块。预览卡之后必须另起一段，**原样**输出上面那句收尾（不得改字；不要写进「解释」或提醒块）。单条仍用 `## commit 1`，不要写成 `待确认 · 1/1`。对已含提醒的预览给出独立的「提交」即按预览提交，不必再点名。

尚未出示这张预览时，「帮我提交」「合为一个 commit」「提交并 push」「提交并push」只用来进入流程，不是确认；**禁止**因此同轮 commit 或 push。

## 4. 等待确认或改稿

预览后看这句话是不是在下令做 commit（独立的「提交」），不要求等于「提交」两个字。

| 用户说的 | 动作 |
|---|---|
| 尚未出示预览时的「提交」「帮我提交」「可以提交」「提交并 push」等 | 只走第 3 步出预览与固定收尾；**不要**第 5 步；**不要** push |
| 独立的「提交」（预览已出示后）：「提交」「确认提交」「帮我提交」「提交吧」「那就提交」「好的，提交吧」「可以提交」 | 按预览执行第 5 步，不要 `git push` |
| 「提交并 push」（预览已出示后） | 按预览执行第 5 步；commit 与自检都成功后再一次 `git push` |
| 「只提交 commit 1」（预览已出示后） | 等于批准该条，执行第 5 步 |
| 单独的「确认」「可以」「好的」「行」「ok」「lgtm」「就这样」，或「可以提交吗」「提交吗」 | 不算确认；可提醒回复「提交」或「提交并 push」 |
| 提交已成功后说「帮我 push」「推一下」或 `git push` | 对当前上游一次 `git push`；不要 `--force`；没有上游则报告且不要 `push -u`；成功后用第 7 步 push 回执 |
| 改 emoji / scope / 标题 / 正文（没说提交） | 更新预览卡（含固定收尾），仍然不提交 |
| 同一句改标题 / emoji / scope / 正文并含独立的「提交」 | 按新稿执行第 5 步，不要再出一轮预览 |
| 「拆开」「还是分批」（即使带「提交」） | 改读 `batch-commit.md`，重出整单预览，不在这里提交 |
| 「合为一条」「合为一条并提交」 | 已在 single 时继续本预览；不要当成跳过预览，也不要同轮提交 |
| 「不要提交」这条 / 不要提交某个 commit | 停止并说明没有待提交项；文件留在工作区；不要 `git restore` / `checkout` / `reset` |
| 强调「不需要预览」「跳过预览」「不要预览」 | 可跳过预览，直接第 5 步；消息仍须遵守 `commit-convention.md` |
| 「直接提交」或只给了标题，但没强调不需要预览 | 仍出示预览与固定收尾，不提交 |

## 5. 确认后执行提交

推荐 `printf` 管道到 `git commit --file -`，避免空行丢失。不要把消息写到固定路径。不要写入 `AI-Co-Authored-By:`、`Co-authored-by:`、`Jira-Refs:`。

锁路径 = 该条预览「改动部分」列出的仓库相对路径（跳过预览时，等于该条实际要提交的路径）。rename / delete 要把预览里的旧路径和新路径都列入。`git commit --only --` 只提交这些路径；其它已暂存文件不进入这次 commit，提交后仍留在 index。

默认整棵工作树时，先 `git add --` 同一份路径（untracked 必须先被认识）。用户只要暂存区时，不要 add。只要暂存区时，先对这些路径跑 `git diff`：非空则停止并说明无法只提交 staged hunk，不要 `git add`，也不要 `git commit --only`（它吃的是工作区）。

```bash
git add -- src/charts/EmptyState.tsx src/charts/ExportButton.tsx

printf '%s\n' \
':sparkles: (charts) 增加空数据占位' \
'' \
'- 折线图无数据时展示占位图' \
'- 导出入口改为禁用而不是报错' \
| git commit --file - --only -- \
  src/charts/EmptyState.tsx \
  src/charts/ExportButton.tsx
```

若有 `BREAKING CHANGE:`，标题用 `:emoji: (scope) ! subject`，body 与 footer 之间留一个空行：

```bash
printf '%s\n' \
':bug: (charts) ! 拒绝重复导出' \
'' \
'- 重复导出请求改为立即失败' \
'' \
'BREAKING CHANGE: 重复导出现在会直接报错' \
| git commit --file - --only -- \
  src/charts/ExportButton.tsx
```

Body 含反引号时尤其不要改用多个 `-m`。

若用户批准的是「提交并 push」，先做第 6 步自检，通过后再对当前分支上游执行一次 `git push`。不要 `--force` 或 `--force-with-lease`。没有上游则报告原因并停止，不要 `git push -u`。该次回复只批准「提交」时不要 push。提交成功后用户再说「帮我 push」「推一下」或 `git push`，自检已通过且有上游时再一次 `git push`。自检失败则不要 push。

## 6. 提交后自检

校验 header（shortcode + **必写** scope）：

```bash
git log -1 --pretty=%B | head -n 1 | grep -Eq '^:[a-z0-9_+-]+: \([^)\s]+\)( !)? .+'
```

检查空行（`%B` 去掉第一行后还有非空行时，`%b` 必须非空；必须带 `else`，不要收成 `&& … || echo FAIL`）：

```bash
if git log -1 --pretty=%B | tail -n +2 | grep -q .; then
  git log -1 --pretty=%b | grep -q . && echo OK || echo FAIL
else
  echo OK
fi
```

确认没有禁止的页脚：

```bash
git log -1 --pretty=%B | grep -Ei '^(AI-Co-Authored-By:|Co-authored-by:|Co-Authored-By:|Jira-Refs:)' && echo FAIL || echo OK
```

对照该条预览路径（rename 用 `--name-status`，看旧路径与新路径是否都在）：

```bash
git show --name-only --pretty=format: HEAD
```

列出的路径必须等于该条预览「改动部分」的仓库相对路径（跳过预览时，等于该条实际要提交的路径）。多了、少了或对不上都算失败。

再看 subject / body 是否仍是本次语言（默认中文）。不要在未确认时 `git commit --amend`。

自检失败则停止并报告，不要输出第 7 步成功回执；恢复动作见 `troubleshooting.md`。自检通过后输出第 7 步回执。

## 7. 成功回执

回执是带槽位的样例，不要改结构。先 `git status --short`：工作区不干净就不要写「应已无未提交变更」，改为说明还剩什么。短 hash 与标题用 `git log`；文件数与 ± 行用 `git show --stat`（只有插入写成 `+N 行`，有删除写成 `+A / -B 行`）。括号里点到模块/产物即可。origin 主机是 `github.com`（含 SSH）时用「GitHub」，否则把开头里的 GitHub 改成「远程」。SSH origin 转成 https 网页地址再写 `仓库地址：`；推不出来就省略该行。`Commit：` 块只列本次新建的 commit；分支行「含 … 提交」列这次 `git push` 实际送出的短 hash（可能含更早未推送的）。失败不要用这些开头。

`Commit：` / `标题：` / `变更：`，以及 `分支：` / `仓库地址：`，同一组写成 Markdown 无序列表（每项 `- ` 起头），组内不要空行。开头句与工作区句仍是段落。组与组之间（例如 Commit 块和「当前工作区」、工作区句和 push 信息块）仍空一行。

只提交成功（该次未 push）：

```markdown
提交已完成。

- Commit： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行（空数据占位与导出禁用）

当前工作区应已无未提交变更。若要推到 owner/repo，可以说一声我帮你执行 git push。
```

没有 origin 时去掉最后一句邀 push。

「提交并 push」都成功：

```markdown
已提交并推送到 GitHub。

- Commit： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行（空数据占位与导出禁用）

当前工作区应已无未提交变更

- 分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）
- 仓库地址：https://github.com/owner/repo
```

上面 `Commit：` 只有本次新建的 `a1b2c3d`；分支行可以同时列出更早未推送的 `d0e8902`。不要再邀请用户 push。

提交成功之后再 push 成功：

```markdown
已推送到 GitHub。

- 分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）
- 仓库地址：https://github.com/owner/repo
```

不要再列出 `Commit：` 块。
