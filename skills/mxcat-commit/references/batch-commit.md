# Batch Commit 详细流程

默认读取本文。仅当用户明确要求「合为一个 commit」（或「合成一条」「不要拆」「就提交一条」）时改走 `single-commit.md`。

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
- 本技能目录的提交入口（预览已确认）。当前 shell 是 sh、bash 或 zsh 时用 `scripts/commit_one`；当前 shell 是 Windows PowerShell 时用 `scripts/commit_one.ps1`。默认整棵工作树时带 `--add`；只要暂存区时不带 `--add`
- `git push`（仅预览后「提交并 push」且全部预定 commit 成功，或提交成功后再说 push；不要 `--force`，没有上游不要擅自 `-u`）

禁止：
- `--force` / `--force-with-lease`
- 擅自 `git push -u`
- 丢掉的预览文件 `git restore` / `checkout` / `reset`
- 自动 `git reset` 已成功的 batch 条目
- 未确认 `git commit --amend`
- 绕过当前环境的入口直接 `git commit`
- 独立 index、shadow worktree、rebase、stash

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
git diff --numstat
git diff --cached --numstat
```

按语义拆成多条 commit，例如同一模块/同一意图放一起，无关改动拆开。每条都必须能独立构成合法消息（必写 `(scope)`、默认中文）。不要先写标题再反推 diff。

若路径明显是密钥、凭证或个人信息，且尚未进入 HEAD（未跟踪或 staged 新增），仍写进某条「改动部分」，预览里提醒；不要因为这类文件就停止或从预览拿掉。

`.agents/skills/*` 默认与业务拆成不同条目。用户明确要求合并，或改走「合为一条」，才允许混入。

`git diff --numstat`（以及 `--cached`）两列都是 `-` 的 binary，默认不与功能文件同条，解释须点名这是二进制。用户明确要求合并或合为一条时允许混入。

每条 commit 记下将进入这条 commit 的路径（预览「改动部分」的仓库相对路径，也就是该条 `commit_one` 的路径参数）。不要把预览里没列出的文件塞进某条。

同一个已跟踪文件可以出现在多条里。每条「改动部分」标明这一条带走的 hunk，这些 hunk 必须来自当时 `git diff HEAD` 里该文件的完整 hunk，各条之间不重叠。解释仍不逐行复述 diff。二进制、尚未进入 HEAD 的新文件，或 rename / copy 同时还要拆内容时，先停止并说明，不要退回整文件提交。

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
- 改动部分：`src/charts/EmptyState.tsx` 新增占位图；`src/charts/ExportButton.tsx` 在无数据时改为 disabled；`.env`

## commit 2

标题
:wrench: (charts) 调整空数据文案配置

正文
- 占位文案改为可配置

解释
- :wrench: 因为这是配置，不是新功能
- scope 仍用 charts
- 改动部分：`src/charts/charts.config.ts` 增加 emptyState 文案字段

提醒
- `.env` 看起来是密钥/凭证，且从未进过仓库。确认提交会把它写进历史。

尚未提交。回复「提交」或「提交并 push」。
```

每条解释必须覆盖：为何这个 emoji、为何这个 scope、**改动了哪些部分**。点到模块/文件/行为即可；列出的每个文件须用仓库相对路径写在反引号里（便于跳转到对应文件），需要定位改动行时可用 `` `startLine:endLine:path` `` 代码引用。不要只写裸文件名、不要逐行复述 diff。有尚未进入 HEAD 的密钥/个人信息时，这些路径仍写在某条「改动部分」；全部条目之后、固定收尾之前列出提醒（仓库相对路径、反引号），说明确认提交会写入历史。无此类路径则不要该块。全部条目之后必须另起一段，**原样**输出上面那句收尾（不得改字；不要写进某条的「解释」或提醒块）。条目标题用 `## commit N`，不要写成 `待确认 · 1/N`。对已含提醒的预览给出独立的「提交」即按预览提交，不必再点名。

尚未出示这张整单预览时，「帮我提交」「按逻辑分批提交」「提交并 push」「提交并push」只用来进入流程，不是确认；**禁止**因此同轮 commit 或 push。

## 4. 等待整单确认或改稿

预览后看这句话是不是在下令做 commit（独立的「提交」），不要求等于「提交」两个字。

改稿时认标题上的 `commit N`，不要把「第二条」当成当前列表下标（丢掉 2 后，列表上第二张是 `commit 3`）。对不上某个 `## commit N` 就问，不要猜、不要提交。

丢掉某条后剩余条目保留原号：原 `## commit 1` / `## commit 2` / `## commit 3` 丢掉 2 后，重出 `## commit 1` 与 `## commit 3`，不要填补空号。

合并两条时，留下较小号（1 和 3 合并后还叫 `## commit 1`，3 消失）。

拆开某条时，原号留给拆出的第一条；新条用本计划曾经用过的最大编号 + 1（含已丢掉或已合并消失的号）。例如曾分配 1、2、3 且 2 已丢掉，把 commit 3 拆成两条 → `## commit 3` 与 `## commit 4`。

| 用户说的 | 动作 |
|---|---|
| 尚未出示整单预览时的「提交」「帮我提交」「可以提交」「提交并 push」等 | 只走第 3 步出预览与固定收尾；**不要**第 5 步；**不要** push |
| 独立的「提交」（预览已出示后）：「提交」「确认提交」「帮我提交」「提交吧」「那就提交」「好的，提交吧」「可以提交」 | 按预览顺序执行第 5 步，不要 `git push` |
| 「提交并 push」（预览已出示后） | 按预览顺序执行第 5 步；全部 commit 与自检都成功后再一次 `git push` |
| 「只提交 commit 1」「提交 1 和 3，2 先留着」（预览已出示后） | 按原序只做被点名的条；其余当丢掉：文件留工作区，不要 `git restore` / `checkout` / `reset`，不必再出剩余预览 |
| 「不要提交 commit 2，其余提交」 | 丢掉 2，当场按原序做剩余条，不要再出一轮 |
| 「只提交 commit 1 并 push」 | 只做 commit 1，成功后再一次 `git push`；其余留工作区 |
| 单独的「确认」「可以」「好的」「行」「ok」「lgtm」「就这样」，或「可以提交吗」「提交吗」 | 不算确认；可提醒回复「提交」或「提交并 push」 |
| 提交已成功后说「帮我 push」「推一下」或 `git push` | 对当前上游一次 `git push`；不要 `--force`；没有上游则报告且不要 `push -u`；成功后用第 7 步 push 回执 |
| 改某条 emoji / scope / 标题 / 正文（没说提交） | 更新整单预览（含固定收尾），仍然不提交 |
| 同一句改标题 / emoji / scope / 正文并含独立的「提交」 | 按新稿执行第 5 步，不要再出一轮预览 |
| 「把 commit 1 和 commit 3 合并」「把 commit 2 拆开」（即使带「提交」） | 按上面编号规则重出整单预览（含固定收尾），仍然不提交 |
| 「不要提交 commit N」 / 不要提交某个 commit / 「2 先留着」（没有批准剩余） | 从预览移除该条；对应文件留在工作区；不要对这些文件 `git restore` / `checkout` / `reset`；重出剩余整单与固定收尾（保留原号，例如丢掉 2 后仍是 1 与 3），仍然不提交。若已无剩余条目，停止并说明没有待提交项 |
| 「合为一条」「合为一条并提交」 | 改读 `single-commit.md`，重出 single 预览，不在这里提交，也不算跳过预览 |
| 强调「不需要预览」「跳过预览」「不要预览」 | 可跳过预览，直接第 5 步；消息仍须遵守 `commit-convention.md` |
| 「直接提交」或只给了标题，但没强调不需要预览 | 仍出示整单预览与固定收尾，不提交 |

## 5. 确认后按序提交

对预览中的每一条，按顺序：

1. 路径参数 = 该条预览「改动部分」列出的仓库相对路径。rename / delete 要把旧路径和新路径都列入。丢掉的条目即使仍 staged，也不列入剩余条的参数。脚本路径相对于本技能目录（含 `SKILL.md` 的那一层），不是目标仓库根目录。
2. 默认整棵工作树时带 `--add`。文件只暂存了一截、工作区还有更多改动时，这条 commit 只含 index 里已有的内容，未暂存部分留下。index 与 HEAD 相同、或路径尚未进入 index 时，`--add` 把工作区全文纳入这一条。已暂存的 rename 可以 `--add` 旧路径和新路径；只给旧路径会在提交前退出。已暂存的删除可以 `--add`。删除后又出现的文件不进入 commit。copy 的旧路径按普通文件处理。同一路径的两种写法只换入一次。只要暂存区时不带 `--add`，也不要自己 `git add`。只要暂存区且路径仍有未暂存改动时，脚本提交 index 里已有的内容并留下工作区；index 与 HEAD 相同则在提交前退出。同一文件不是最后一段时，把该条 hunk 写成补丁文件（从 `git diff HEAD` 抄出的完整 hunk，不要用 `/tmp/commit_msg.txt`），调用时加上 `--hunks <file>`。最后一段若只要剩余全部，继续 `--add`，不要再带 `--hunks`。补丁对不上当前 diff 时入口会在提交前退出，不要改成整文件提交。
3. 把消息管道到当前环境的入口，写入该条标题和正文。sh、bash、zsh 用 `scripts/commit_one`；Windows PowerShell 用 `scripts/commit_one.ps1`。每条 commit 各自一条管道，不要复用上一条的消息来源，也不要写到固定路径（包括 `/tmp/commit_msg.txt`）。不要在 PowerShell 里调用没有扩展名的 `commit_one`，也不要在 sh 里调用 `.ps1`。不要绕过入口另写 `git commit`。不要写入 `AI-Co-Authored-By:`、`Co-authored-by:`、`Jira-Refs:`。
4. 入口非 0 即停，与 `single-commit.md` 第 6 步相同。不要另跑 header / 空行 / 页脚 / `git show` 四段命令。
5. 通过后再处理下一条。

```bash
printf '%s\n' \
':sparkles: (charts) 增加空数据占位' \
'' \
'- 折线图无数据时展示占位图' \
'- 导出入口改为禁用而不是报错' \
| scripts/commit_one --add -- \
  src/charts/EmptyState.tsx \
  src/charts/ExportButton.tsx
```

Windows PowerShell：

```powershell
@'
:sparkles: (charts) 增加空数据占位

- 折线图无数据时展示占位图
- 导出入口改为禁用而不是报错
'@ | powershell -NoProfile -File scripts/commit_one.ps1 --add -- src/charts/EmptyState.tsx src/charts/ExportButton.tsx
```

Body 含反引号时不要改用多个 `-m`。不要在未确认时 `git commit --amend`。该次回复只批准「提交」时，全部条目成功后也不要 `git push`。

若用户批准的是「提交并 push」：必须全部预定 commit 与自检都成功后，再对当前分支上游执行恰好一次 `git push`。不要在中间某条之后 push。不要 `--force` 或 `--force-with-lease`。没有上游则报告原因并停止，不要 `git push -u`。已成功的 commit 保留。提交成功后用户再说「帮我 push」「推一下」或 `git push`，有上游时再一次 `git push`。

全部预定条目与自检都成功后，输出第 7 步回执。

## 6. 中途失败则停止

任一条 `commit_one` 失败（含 hook，或入口在提交前拒绝）时：

- **不要**继续创建后续预览中的 commit。
- **不要**假装整单已完成。
- **不要**运行 `git push`。
- **不要**用第 7 步成功回执开头。
- 向用户报告：哪些条目已成功、哪一条失败（含错误摘要）、哪些尚未尝试。
- 已成功的条目保留；不要自动 `reset` 掉它们。是否回滚由用户决定，恢复动作见 `troubleshooting.md`。

## 7. 成功回执

结构与 `single-commit.md` 第 7 步相同。多条新建 commit 时，按提交顺序重复 `Commit：` / `标题：` / `变更：` 列表组（每项 `- ` 起头，组内不要空行，组与组之间空一行）。先 `git status --short` 再决定是否写「应已无未提交变更」。origin 不是 GitHub 时，把开头里的 GitHub 改成「远程」。`分支：` / `仓库地址：` 同样写成列表。

只提交成功（该次未 push）；多条则重复 Commit 块：

```markdown
提交已完成。

- Commit： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行（空数据占位与导出禁用）

- Commit： b2c3d4e
- 标题： :wrench: (charts) 调整空数据文案配置
- 变更： 1 个文件，+8 行（emptyState 文案配置）

当前工作区应已无未提交变更。若要推到 owner/repo，可以说一声我帮你执行 git push。
```

「提交并 push」都成功。下面演示本次只新建一条，但这次 push 还送出了更早未推送的 commit：`Commit：` 块只有新的那条，分支行列出实际送出的两条 hash。

```markdown
已提交并推送到 GitHub。

- Commit： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行（空数据占位与导出禁用）

当前工作区应已无未提交变更

- 分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）
- 仓库地址：https://github.com/owner/repo
```

提交成功之后再 push 成功：

```markdown
已推送到 GitHub。

- 分支： main → origin/main（含 d0e8902 与 a1b2c3d 两条提交）
- 仓库地址：https://github.com/owner/repo
```

不要再列出 `Commit：` 块。
