# Single Commit 详细流程

仅当用户明确要求「合为一个 commit」（或「合成一条」「不要拆」「就提交一条」）时读取本文。默认分批流程见 `batch-commit.md`。

确认前禁止 `git commit`。

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
## 待确认 · 1/1

标题
:sparkles: (charts) 增加空数据占位

正文
- 折线图无数据时展示占位图
- 导出入口改为禁用而不是报错

解释
- :sparkles: 因为这是新的空数据展示，不是修崩溃
- scope 用 charts，改动都在图表模块
- 改动部分：`EmptyState.tsx` 新增占位图；`ExportButton` 在无数据时改为 disabled
```

解释必须覆盖这三项：

1. 为何这个 emoji
2. 为何这个 scope
3. **改动了哪些部分**（模块、关键文件或行为；列出将进入这条 commit 的范围）

点到文件/模块/行为即可，不要逐行复述 diff。

「帮我提交」「合为一个 commit」本身 **不是** 对这张预览卡的确认。

## 4. 等待确认或改稿

| 用户说的 | 动作 |
|---|---|
| 「确认」「可以提交」「lgtm」「就这样」 | 按预览执行第 5 步 |
| 改 emoji / scope / 标题 / 正文 | 更新预览卡，仍然不提交 |
| 「拆开」「还是分批」 | 改读 `batch-commit.md`，不在这里提交 |
| 本轮已给出完整 `:emoji: (scope) subject`，并明确说「直接提交」 | 可跳过预览，直接第 5 步；消息仍须遵守 `commit-convention.md` |
| 给了建议标题但没说「直接提交」 | 仍出示预览，不提交 |

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

自检失败则停止并报告；恢复动作见 `troubleshooting.md`。
