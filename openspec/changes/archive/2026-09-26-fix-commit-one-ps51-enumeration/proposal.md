## Why

在 Windows PowerShell 5.1 上，`scripts/commit_one.ps1` 对 `List[object]` 使用 `@(...)` 会抛出「参数类型不匹配」，在 `git commit` 之前退出。默认的 `--add` 整文件提交因此创建不出 commit。校验脚本和 sh 入口不受影响，但技能在 Windows PowerShell 上的提交入口目前不可用。

## What Changes

- `commit_one.ps1` 在枚举待换入路径和换入记录时，MUST 能在 Windows PowerShell 5.1 上走完，包括待换入列表为空和其中已有条目两种情况。
- 合格消息与路径在该环境下 MUST 能创建 commit；不合格消息仍在创建 commit 之前拒绝。
- sh 入口 `scripts/commit_one`、`scripts/validate` 与 `scripts/validate.ps1` 的规则不变。

## Capabilities

### New Capabilities

### Modified Capabilities

- `mxcat-commit-workflow`: Windows PowerShell 5.1 上，`commit_one.ps1` 枚举待换入列表时不得在 `git commit` 之前因列表包装失败退出。

## Impact

- `skills/mxcat-commit/scripts/commit_one.ps1`：存放待换入路径与换入记录的列表类型。
- 不改提交语义、路径锁、消息检查，也不改 sh 脚本。
