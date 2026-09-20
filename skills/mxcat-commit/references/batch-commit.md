# Batch Commit 详细流程

默认读取本文。仅当用户明确要求「合为一个 commit」（或「合成一条」「不要拆」「就提交一条」）时改走 `single-commit.md`。

只用 `git status`、`git diff`、`git add`、`git commit`。

确认整单之前禁止 `git commit`。

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

若逻辑上只有一组，预览写成 `1/1`，仍走本文，不要改成 single。

## 3. 一次出示整单预览（此时不要提交）

按顺序输出全部条目：

```markdown
## 待确认 · 1/2

标题
:sparkles: (charts) 增加空数据占位

正文
- 折线图无数据时展示占位图
- 导出入口改为禁用而不是报错

解释
- :sparkles: 因为这是新的空数据展示，不是修崩溃
- scope 用 charts，改动都在图表模块
- 改动部分：`EmptyState.tsx` 新增占位图；`ExportButton` 在无数据时改为 disabled

## 待确认 · 2/2

标题
:wrench: (charts) 调整空数据文案配置

正文
- 占位文案改为可配置

解释
- :wrench: 因为这是配置，不是新功能
- scope 仍用 charts
- 改动部分：`charts.config.ts` 增加 emptyState 文案字段
```

每条解释必须覆盖：为何这个 emoji、为何这个 scope、**改动了哪些部分**。点到文件/模块/行为即可，不要逐行复述 diff。

「帮我提交」「按逻辑分批提交」本身 **不是** 对这张整单预览的确认。

## 4. 等待整单确认或改稿

| 用户说的 | 动作 |
|---|---|
| 「确认」「可以提交」「lgtm」「就这样」 | 按预览顺序执行第 5 步 |
| 改某条 emoji / scope / 标题 / 正文 | 更新整单预览，仍然不提交 |
| 「第一条和第三条合并」「把第二拆开」 | 重出整单预览，仍然不提交 |
| 「合为一条」 | 改读 `single-commit.md`，不在这里提交 |
| 本轮已给出每条完整标题，并明确说「直接提交」 | 可跳过预览，直接第 5 步；消息仍须遵守 `commit-convention.md` |
| 给了建议标题但没说「直接提交」 | 仍出示整单预览，不提交 |

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

Body 含反引号时不要改用多个 `-m`。不要在未确认时 `git commit --amend`。

## 6. 中途失败则停止

任一条在 `git add`、`git commit`（含 hook）或自检失败时：

- **不要**继续创建后续预览中的 commit。
- **不要**假装整单已完成。
- 向用户报告：哪些条目已成功、哪一条失败（含错误摘要）、哪些尚未尝试。
- 已成功的条目保留；不要自动 `reset` 掉它们。是否回滚由用户决定，恢复动作见 `troubleshooting.md`。
