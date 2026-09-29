## 1. 待换入判断

- [x] 1.1 在 `scripts/commit_one.ps1` 的 `--add` 与不带 `--add` 两条路径中：index 与 HEAD 的模式或 blob 不同时放入待换入列表，并使用 index 里的模式和 blob；`git diff --quiet` 成功不得跳过这项比较
- [x] 1.2 index 与 HEAD 的模式和 blob 都相同、只是工作区还有改动时，仍按现有规则提交工作区或拒绝，不改成待换入，也不得因此报「没有可提交的已暂存改动」

## 2. 提交

- [x] 2.1 待换入的普通文件模式与 HEAD 不同，且 `core.filemode` 不是 `true` 时：换入完成后用 `GIT_INDEX_FILE` 建临时 index，`read-tree HEAD`，对待换入条目 `update-index --cacheinfo` 或 `--force-remove`，其余路径参数按真实工作区有无加入或删除；再把 `GIT_WORK_TREE` 指到检出该 index 的空目录，`git commit --file` 且不带路径参数
- [x] 2.2 这条路径上不再调用 `update-index --chmod=+x`。`core.filemode=true` 时仍 `chmod` 后走现在的 `git commit --only`。符号链接仍走现有换入，不改成 `cacheinfo`
- [x] 2.3 提交一结束就清除 `GIT_INDEX_FILE`；成功后按临时 index 把本次路径写回真正的 index，其它路径不写。`finally` 再清一次该变量。未创建 commit 时仍用调用前的 index 备份恢复工作区和 index
- [x] 2.4 若 `git commit` 前的刷新把 cacheinfo 的模式改回，在 `git commit` 之前再写一次 cacheinfo。提交后的 `ls-tree` 核对保持现有行为

## 3. 文档

- [x] 3.1 在 `skills/mxcat-commit/CHANGELOG.md` 顶部按现有条目格式记下：文件系统表达不了可执行位时，commit 仍保持 `100755` 或改回的 `100644`
