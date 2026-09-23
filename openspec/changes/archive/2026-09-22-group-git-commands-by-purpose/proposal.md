## Why

`batch-commit.md` 开头把「只用 `git status` / `git diff` / `git add` / `git commit`」写成封闭授权，后面自检和回执却要 `git log` / `git show` / `git cat-file`，仓库地址还暗示 `git remote get-url`。Agent 可能因此不敢跑自检，或自觉越权。`lock-commit-paths` 补了对照 `git show` 之后，开头那句没跟着开。

## What Changes

- 流程说明 MUST 按用途分三族授权 git 命令（写成列表，不要封闭四件套）：分析/自检/回执的只读查询；有门禁的写入（`add` / `commit` / `push`）；点名禁止项。
- single 与 batch 顶部 MUST 使用同一套分族列表。`single-commit.md` 现在没有「只用」句，也要补上，避免一边关一边开。
- 用户确认撤回时的 `git reset --soft` 仍只属于 troubleshooting 恢复通道，MUST NOT 写进常规写入族。
- 不引入执行器、独立 index 或 shadow worktree。不改 `--only` 锁路径、预览门禁确认词或固定收尾。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 「常规 git 命令」从举例四件套改为按用途分族；只读查询与有门禁的写入合法，点名禁止项仍非法。

## Impact

- 修改 `references/batch-commit.md` 开头「只用」句，改成三族列表。
- 修改 `references/single-commit.md` 顶部，与 batch 同一套列表。
- `references/troubleshooting.md` 点明用户确认撤回时才允许 `git reset --soft`；不要把 reset 写进常规写入族。
- `SKILL.md` 不展开命令表。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该授权修正。
- 不新增脚本或测试套件。
