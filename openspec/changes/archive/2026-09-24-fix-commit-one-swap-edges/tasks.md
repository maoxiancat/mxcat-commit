## 1. commit_one

- [x] 1.1 改 `scripts/commit_one`：pending 按折好的仓库相对路径去重，同一路径只保留第一次。不带 `--add` 时，即使有 `--hunks`，补丁以外的路径仍按 index 判断：与 index 一致则不换入；index 与 HEAD 相同但工作区有未暂存改动则在 commit 前退出；index 相对 HEAD 有改动则换入该 index 条目
- [x] 1.2 改 `scripts/commit_one`：仓库相对路径上的 `git diff`、`git ls-files`、`git ls-tree`、`git update-index` 用 `git -C` 仓库根。`git diff --quiet`、`git add`、`git commit --only` 仍用用户原来的参数
- [x] 1.3 用同一规则改 `scripts/commit_one.ps1`。补丁路径保持已有去重。`Assert-SplittablePath` 以及尚未加 `-C` 的 `ls-files`、`ls-tree`、`update-index` 改到仓库根

## 2. 测试

- [x] 2.1 在 `skills/mxcat-commit/tests/check_scripts` 用临时仓库覆盖：`./f.txt` 与 `f.txt` 同一次传入时，commit 只含 index，未暂存内容仍留在工作区。`--hunks` 提交 A 的一段时，旁路 C 的 commit 只含 index，C 的未暂存内容和 A 的未选 hunk 都留在工作区。C 的 index 与 HEAD 相同但工作区有未暂存改动时，在创建 commit 之前退出
- [x] 2.2 在子目录调用：只提交已暂存且工作区另有内容时能创建 commit，diff 等于 index。`--hunks` 为完整 hunk 子集时能创建 commit，未选 hunk 留在工作区。若 `check_scripts` 当前不在工作区，只补回能跑这两条和 2.1 的检查，不改其它用例的断言

## 3. 文档

- [x] 3.1 改 `references/troubleshooting.md`：同一路径两种写法、`--hunks` 旁路的已暂存文件、子目录中的换入。未暂存内容不得从工作区消失，也不得进入 commit
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
