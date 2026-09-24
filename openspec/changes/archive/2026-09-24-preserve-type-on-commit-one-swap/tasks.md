## 1. commit_one

- [x] 1.1 改 `scripts/commit_one`：待换入条目记下模式和 blob。`--hunks` 从 apply 后的临时 index 读，不带 `--add` 时从真实 index 读，并与 `HEAD` 的模式和 blob 一起比较。同一路径只换入一次。`100644` / `100755` / `120000` 以外的模式在改工作区之前拒绝
- [x] 1.2 备份与恢复改用不跟随符号链接的拷贝。先删路径再按模式写入：普通文件写字节并设置可执行位，符号链接用 blob 原始字节作链接文本。文件系统表达不了 `100755` 时，在 `git commit --only` 之前 `git update-index --chmod=+x`。提交后用 `git ls-tree` 同时核对模式和 blob
- [x] 1.3 用同一规则改 `scripts/commit_one.ps1`。创建符号链接失败时在 `git commit` 之前退出，不把链接目标写成普通文件

## 2. 测试

- [x] 2.1 用临时仓库覆盖：同一路径两段 `diff --git` 时 commit 只含选中 hunk，未选中 hunk 仍留在工作区。index 为 `120000`、工作区已是普通文件时，commit 仍是符号链接，工作区恢复为普通文件。index 为 `100755` 且工作区文件已删除时，commit 保持 `100755`，工作区仍无该文件
- [x] 2.2 用临时仓库覆盖：工作区是 `100644`、index 是 `100755` 时 commit 为 `100755`，工作区模式与内容不变。只暂存可执行位、blob 与 `HEAD` 相同且工作区另有内容时，commit 只带走模式。链接目标不一致时不改目标文件内容。悬空符号链接仍可提交 index 条目，且不创建链接目标

## 3. 文档

- [x] 3.1 改 `references/troubleshooting.md`：重复 `diff --git`、符号链接和可执行位在提交后，工作区仍是调用前的路径；历史中的类型和模式与要提交的条目一致。模式或类型对不上时 commit 保留且不 reset
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
