## Context

见 `proposal.md` 的 Why。`commit_one.ps1` 用 `List[object]` 存放待换入路径（`$pending`）和换入记录（`$made`）。枚举时写成 `@($pending)`、`@($made)`，`finally` 里再 `@($swaps)`。Windows PowerShell 5.1 对 `List[object]` 做 `@(...)` 会抛出 ArgumentException（「参数类型不匹配」），空列表和已有 hashtable 都会中。`List[string]` 上的 `@(...)` 不受影响。整文件 `--add` 时 `$pending` 经常为空，崩溃发生在 `git commit` 之前。

## Goals / Non-Goals

**Goals:**

- Windows PowerShell 5.1 上，待换入列表为空或已有条目时，枚举都能走完。
- 合格消息与有差异的路径仍能创建 commit；不合格消息仍在创建 commit 之前拒绝。
- 现有 `@($pending)`、`@($made)`、`@($swaps)` 不必改成另一套枚举写法。

**Non-Goals:**

- 不改 sh 的 `commit_one` / `validate`，也不改 `validate.ps1` 的检查规则。
- 不改路径锁、hunk、index 恢复或提交语义。
- 不把 `List[string]` 的 `@(...)` 一并改掉。

## Decisions

### 1. 两处 `List[object]` 改为 `List[hashtable]`

`$pending` 与 `$made` 里放的都是 hashtable。改成 `List[hashtable]` 之后，现有 `@(...)` 在 Windows PowerShell 5.1 上可以枚举空列表和已有条目。`$swaps = @($made)` 得到的也是 hashtable 集合，`finally` 里的 `@($swaps)` 不再碰到 `List[object]`。

备选：只在四处把 `@($list)` 换成 `@($list.ToArray())`，或直接 `foreach` 列表。能过这一次，但只要以后又把 `List[object]` 包进 `@(...)`，5.1 上会复发。改元素类型让现有包装保持有效。

备选：升级到 PowerShell 7。技能入口写明的是 Windows PowerShell，不能把 5.1 排除在外。

## Risks / Trade-offs

- [以后往这两个列表加入非 hashtable] → `Add` 会在写入时失败，而不是拖到枚举。当前两处 `Add` 都是 hashtable。
- [只改了类型、漏了一处 `List[object]`] → 实现时只改 `$pending` 与 `$made` 的构造，并确认没有第三处 `List[object]`。
