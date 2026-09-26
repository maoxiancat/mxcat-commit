## 1. 列表类型

- [x] 1.1 把 `scripts/commit_one.ps1` 里 `$pending` 与 `$made` 从 `List[object]` 改为 `List[hashtable]`，保留现有 `@($pending)`、`@($made)` 与 `@($swaps)`
- [x] 1.2 确认该文件没有第三处 `List[object]`，且 `List[string]` 的 `@(...)` 未改

## 2. Windows PowerShell 5.1 核对

- [x] 2.1 在临时仓库用合格消息调用 `commit_one.ps1 --add`，路径为尚未进入 index 的整文件：创建 commit，文件集合含该路径，不在 `git commit` 之前因枚举退出
- [x] 2.2 同环境下走一条会在 `git commit` 之前记下至少一条待换入路径的调用：枚举完成并创建 commit
- [x] 2.3 把不合格 header 管道给 `commit_one.ps1`：非 0 退出，且不创建 commit
