## Context

见 `proposal.md` 的 Why。`--hunks` 与不带 `--add` 的 index 内容都走同一条换入：`record_swap` 用 `cp -p` 备份，再用 `git cat-file blob > 路径` 写成普通文件，`git commit --only` 按磁盘上的类型和模式提交，退出时按记录顺序放回。`commit_one.ps1` 用 `Copy-Item` 做同样的事。事后核对只比 blob。

仍用 `git commit --only`，这样 hook 会跑，未列入本次的已暂存路径也不会被带进 commit。

## Goals / Non-Goals

**Goals:**

- 换入一次只针对一个路径，备份的是调用前的路径本身。
- `git commit --only` 看到的类型和模式与要提交的 index 条目一致。
- 提交后的核对能抓住模式或类型写错。

**Non-Goals:**

- 不改成 `git commit-tree`，也不为这次提交替换仓库的真实 index。
- 不处理 `160000` 子模块，以及 `100644`、`100755`、`120000` 以外的模式。
- 不改默认 `--add` 的整文件路径。

## Decisions

### 1. 待提交条目记成模式加 blob

`--hunks` 在临时 index 上 `git apply --cached` 之后，用 `git ls-files -s` 读取该路径的模式和 blob。不带 `--add` 时从真实 index 读同一格式，再和 `git ls-tree HEAD` 的模式与 blob 比较。两者都相同才按「没有可提交的已暂存改动」退出。

备选：继续只存 blob，提交后再用 `git ls-tree` 发现模式错了再失败。那样错误 commit 已经写下，而且符号链接仍会在提交前写穿目标文件。

### 2. 同一路径只换入一次

补丁路径列表按出现顺序去重后再写入待换入列表。`git apply --cached` 仍应用整份补丁，blob 用应用后的最终结果。恢复时每个路径只有一份调用前的备份。

备选：同一路径出现两次就拒绝。复现里这种补丁的 commit 内容是对的，丢掉的是工作区里没选中的 hunk。去重能留下这些 hunk。

### 3. 备份和恢复都不跟随符号链接

先把路径本身拷走（`cp -P`，PowerShell 拷链接而不是目标），再删掉该路径，然后按模式新建：

- `100644` / `100755`：写入 blob 字节，再把可执行位设成该模式。文件还在且模式不同时也要设，不能依赖截断原文件保住权限。
- `120000`：用 blob 的原始字节作为链接文本创建符号链接，不追加换行。

恢复时先删掉换入后的路径，再把备份放回。调用前路径不存在则删除换入结果。悬空链接按链接本身备份，不读取目标。

其它模式在删除路径之前拒绝。

备选：用 `git checkout-index` 把条目检出到临时目录再挪过来。它也会按模式建文件，但和现有「备份后换入、退出时放回」的清理不好接，符号链接仍要单独避免写穿。

### 4. 平台表达不了模式时，在 commit 前写进 index

`core.filemode=false` 时，`git commit --only` 不会从文件系统读可执行位。换入后若文件系统不能表达 `100755`，先对该路径 `git update-index --chmod=+x`，再 `git commit --only`。符号链接必须是链接本身，不能退回普通文件。提交后用 `git ls-tree HEAD` 同时核对模式和 blob。不一致就非 0 退出，commit 保留，工作区仍按备份放回。

## Risks / Trade-offs

- [hook 在换入后的工作区上改写了模式或内容] → 提交后的模式与 blob 核对会非 0 退出。commit 保留，工作区放回调用前。与现有 hunk 核对的失败语义相同。
- [符号链接文本含尾部换行，命令替换把换行吃掉] → 链接文本直接取 blob 原始字节，不经过会去掉尾部换行的替换。
- [Windows 上创建符号链接需要权限] → 创建失败就在 `git commit` 之前退出，不把链接目标写成普通文件。工作区放回调用前。
- [`update-index --chmod` 在 `--only` 之后被工作区的 644 盖掉] → 能 `chmod` 的平台先改工作区文件。核对失败则非 0 退出。

## Migration Plan

只改两个入口脚本、`tests/check_scripts`、`troubleshooting.md` 和 CHANGELOG。已有历史 commit 不改写。调用方不需要新参数。回滚是恢复这两个脚本。
