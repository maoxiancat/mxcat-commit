## 1. commit_one

- [x] 1.1 改 `scripts/commit_one`：`--add` 在换入前按折好的仓库相对路径去重，同一路径只保留第一次调用前备份。已进入 pending 的路径不再 `git add`。index 与 HEAD 相同、因此要 `git add` 的路径，重复参数不取消第一次 `git add`
- [x] 1.2 改 `scripts/commit_one`：HEAD 有、index 与工作区都没有的路径跳过 `git add`，交给 `git commit --only` 提交删除。工作区已删但 index 仍有该路径时仍 `git add`。删除已暂存且文件又出现时，先备份并挪走该文件再提交删除，成功与创建 commit 之前的失败都放回；提交后核对期待 HEAD 中没有该路径
- [x] 1.3 改 `scripts/commit_one`：rename 旧路径判断只匹配 `R`。git 仍识别为 rename 且参数只有旧路径时，在创建 commit 之前退出，不提交删除。新旧路径都在时仍提交这次 rename。相似度下降成删除加新增时，旧路径按已暂存删除处理，不按 rename 拒绝。copy 的旧路径按普通文件处理
- [x] 1.4 用同一规则改 `scripts/commit_one.ps1`。去重和跳过发生在路径进入待 `git add` 列表之前

## 2. 测试

- [x] 2.1 在 `skills/mxcat-commit/tests/check_scripts` 用临时仓库覆盖：`--add` 同时传入 `./note.txt` 与 `note.txt` 且 index 与工作区不一致时，commit 只含 index，未暂存内容仍留在工作区；index 与 HEAD 相同时，重复参数仍提交工作区全文
- [x] 2.2 覆盖已暂存删除的 `--add`、工作区已删但尚未暂存的 `--add`、删除已暂存且文件又出现时带与不带 `--add` 都提交删除并留下工作区，以及提交前失败时该文件回到调用前
- [x] 2.3 覆盖：相似度下降后 `--add` 新旧两个路径仍能提交删除加新增；只传仍被识别为 rename 的旧路径时在 commit 前退出且 index 保持改名；相似度不足时只传旧路径仍提交删除，新路径留在 index；copy 旧路径有未暂存改动时 `--add` 只提交 index
- [x] 2.4 若 `check_scripts` 当前不在工作区，只补回能跑 2.1 到 2.3 的检查，不改其它用例的断言

## 3. 文档

- [x] 3.1 改 `references/troubleshooting.md`、`references/single-commit.md`、`references/batch-commit.md`：同一路径只换入一次、已暂存删除、删除后又出现的文件、相似度下降后的两个路径、只给 rename 旧路径会在提交前退出、copy 旧路径不按 rename 跳过
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
