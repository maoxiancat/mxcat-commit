## 1. commit_one

- [x] 1.1 改 `scripts/commit_one`：工作区没有该路径时，HEAD 有且 index 的模式或 blob 与 HEAD 不同，则记入 pending，不 `git add`。换入沿用调用前路径不存在的记录，返回后工作区仍缺失；创建 commit 之前失败时同样缺失，并把 index 拷回。index 与 HEAD 的模式和 blob 相同则仍 `git add`。尚未进入 HEAD 的路径不记入 pending
- [x] 1.2 用同一三分支改 `scripts/commit_one.ps1`。判断发生在路径进入待 `git add` 列表之前

## 2. 测试

- [x] 2.1 在 `skills/mxcat-commit/tests/check_scripts` 用临时仓库覆盖：已跟踪文件 index 相对 HEAD 有内容改动、工作区已删除时，`--add` 的 commit 等于调用前 index，返回后工作区仍缺失；只改了模式时 commit 带上该模式
- [x] 2.2 覆盖：index 与 HEAD 相同且工作区已删除时，`--add` 仍提交删除；新文件只在 index、工作区已删除时，`--add` 在创建 commit 之前退出，没有新 commit，index 与调用前一致；已暂存修改且工作区已删除、提交前失败时，工作区仍缺失且 index 回到调用前
- [x] 2.3 若 `check_scripts` 当前不在工作区，只补回能跑 2.1 和 2.2 的检查，不改其它用例的断言

## 3. 文档

- [ ] 3.1 改 `references/troubleshooting.md`、`references/single-commit.md`、`references/batch-commit.md`：index 已有改动且工作区文件缺失时 `--add` 提交 index 并留下缺失；index 与 HEAD 相同时仍提交删除；新文件只暂存再被删掉时 `--add` 仍在提交前退出
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
