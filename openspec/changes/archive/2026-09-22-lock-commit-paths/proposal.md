## Why

`single-commit.md` / `batch-commit.md` 现在是「`git add` 预览路径，再 `git commit --file`」。这会提交整个 index，不是预览列出的那几个文件。用户事先 `git add` 过别的东西、上一条失败留下暂存、或丢掉的预览条目仍在 index 里时，都会得到正确消息 + 错误文件集合。自检只看标题、空行和禁页脚，对不上也不会停。

## What Changes

- single 与 batch 确认后的提交 MUST 锁路径：`git commit --file <msg> --only -- <该条预览路径>`。其它已暂存路径 MUST NOT 进入该 commit，提交后仍留在 index。
- 默认整棵工作树时仍先 `git add --` 该条预览路径（untracked 必须先被认识）；用户只要暂存区时不要 add。只要暂存区且这些路径还有 unstaged，MUST 停止，不要用 `--only` 把工作区多出来的 hunk 带进去。
- 提交后自检 MUST 用 `git show --name-only`（rename 用 `--name-status`）对照该条预览路径；对不上按现有中途失败处理。
- preview-gate 除消息一致外，创建的 commit 文件集合 MUST 等于该条预览列出的路径。
- 不引入执行器、独立 index 或 shadow worktree。失败仍留下已成功的 commit，不要自动 reset。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 提交命令锁预览路径；文件集合必须等于预览；自检对照 `git show`；只要暂存区遇到混合文件则停止。
- `mxcat-commit-preview-gate`: 批准后创建的 commit，文件集合必须与该条预览路径一致。

## Impact

- 修改 `references/single-commit.md`、`references/batch-commit.md` 第 5 步样例与第 6 步自检，以及 `references/troubleshooting.md` 的路径对不上处理。
- `SKILL.md` 不必展开命令；若摘要需要点到「只提交预览路径」，保持路由器层简短。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不新增脚本、测试套件或 Python 依赖。
