## 1. commit_one

- [x] 1.1 改 `scripts/commit_one`：目录预检通过后、第一次 `git add` 或 `git commit` 之前，把 `git rev-parse --git-path index` 拷到临时文件。`git commit` 返回 0 后、提交后对照之前置成功标志。`EXIT` trap 在标志未置上时把拷贝写回 index，再恢复 hunk 换入的工作区。不设置 `GIT_INDEX_FILE` 来创建 commit，不用 `git reset`
- [x] 1.2 用同一规则改 `scripts/commit_one.ps1`：`finally` 在 commit 未成功时拷回 index

## 2. 测试

- [x] 2.1 用临时仓库覆盖：`--add` 夹带相对 HEAD 与 index 都无差异的文件时不创建 commit，index 与调用前一致。`git add` 因忽略文件失败时，前面已 add 的文件也回到调用前。工作区等于 HEAD、index blob 不同时，失败后 index blob 仍是调用前那一版
- [x] 2.2 用临时仓库覆盖：pre-commit hook 非 0 时不创建 commit，HEAD 与 index 都是调用前。`--add` 成功时该路径的 index blob 等于新建 commit，未列入路径的已暂存文件仍留在 index。提交后对照失败时 commit 仍是 HEAD，已提交路径的 index blob 等于该 commit

## 3. 文档

- [x] 3.1 改 `references/troubleshooting.md`：提交前失败（含 hook、忽略文件、未改动路径）时 commit 未创建且 index 与调用前一致；提交后对照失败时 commit 保留且不 reset
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
