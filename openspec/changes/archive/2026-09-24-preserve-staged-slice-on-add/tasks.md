## 1. commit_one

- [x] 1.1 改 `scripts/commit_one`：`--add` 时按路径分类。index 相对 HEAD 已有差异且工作区相对 index 还有差异的路径不 `git add`，交给现有的 index blob 换入路径。已暂存 rename 的旧路径不 `git add`，仍传给 `git commit --only`。index 与 HEAD 相同或尚未进入 index 的路径仍 `git add --`
- [x] 1.2 用同一分类改 `scripts/commit_one.ps1`：部分暂存写入已有的 `$pending`，不再放进要 `git add` 的列表；已暂存 rename 的旧路径不 `git add`

## 2. 测试

- [x] 2.1 用临时仓库覆盖：`--add` 时文件只暂存了一截，commit 的 diff 等于 index 相对 HEAD，未暂存改动仍留在 `git diff`。index 与 HEAD 相同或路径尚未进入 index 时，`--add` 仍提交工作区全文
- [x] 2.2 用临时仓库覆盖：`git mv` 之后 `commit_one --add --` 旧路径和新路径能创建一次 rename，不以 pathspec 失败。工作区已改名但尚未暂存时，`--add` 两个路径仍能交成一次 rename。不带 `--add` 的部分暂存路径行为与改前一致

## 3. 文档

- [x] 3.1 改 `references/single-commit.md` 与 `references/batch-commit.md`：部分暂存时 `--add` 只提交 index 那一截，未暂存改动留下；已暂存 rename 可以 `--add` 旧路径和新路径
- [x] 3.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
