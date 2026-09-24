## Context

见 `proposal.md` 的 Why。`--add` 在 index 相对 HEAD 有改动且工作区还有更多内容时，把该路径记入 pending，提交前换成 index 的模式与 blob，退出时按记录顺序放回。不带 `--add` 时，同一仓库相对路径已在 pending 里会跳过。`--add` 这条循环没有同样的判断。

已暂存删除在 index 里没有条目。现有换入假定能把 index blob 写回工作区，再交给 `git commit --only`。`git add --` 只匹配工作区或 index 里存在的路径。

`staged_rename_old` 用 `git diff --cached -M` 同时匹配 `R` 与 `C`。rename 的旧路径已经不在工作区；copy 的旧路径还在。

## Goals / Non-Goals

**Goals:**

- `--add` 的重复路径在换入前按折好的仓库相对路径去重，每个路径只留第一次调用前备份。
- 已暂存删除、删除后又出现的文件、相似度下降后的改名，都按「index 里这条路径是否还在」处理，而不是按「文件不存在就跳过」。
- 只传仍被识别为 rename 的旧路径时，在 `git commit` 之前退出。
- sh 与 PowerShell 使用同一判断。

**Non-Goals:**

- 不把相似度已低到删除加新增的旧路径，当成 rename 拒绝。
- 不改成 `git commit-tree`，也不替换仓库的真实 index。
- 不改 index 与 HEAD 相同、只工作区有改动时的全文 `--add`。
- 不改工作区与 index 已经一致时直接 `--only` 的路径。

## Decisions

### 1. 换入前按折好的路径去重

`--add` 追加 pending 之前，看该仓库相对路径是否已经在列。已在列则跳过，包括第二次换入和第二次 `git add`。恢复顺序不变，每个路径只有第一次备份。

index 与 HEAD 相同、因此第一次要 `git add` 的路径，不因为参数里还有第二次就跳过这次 `git add`。去重只挡住已经进入 pending 的路径，以及同一次循环里已经处理过的路径；第一次的 `git add` 必须发生。

备选：换入时若路径已换过就跳过。第二次备份到的已经是 index 内容，调用前的工作区留不下来。

### 2. 已暂存删除不走 `git add`，也不把「文件不存在」当成条件

跳过 `git add` 的条件是：HEAD 有该路径，index 没有，工作区也没有。commit 交给 `git commit --only`，此时工作区与 index 都缺这个文件，提交的是删除。

工作区删了但 index 仍有该路径时，仍执行 `git add --`，把未暂存删除收进 index。两边都没有、HEAD 也没有的路径，继续让 `git add` 失败。

备选：`git add -A -- <path>`。路径既不在工作区也不在 index 时，pathspec 一样匹配不到。

### 3. 删除已暂存但文件又出现时，提交「路径不存在」

`git diff` 看不到这个未跟踪文件。检测到 HEAD 有、index 没有、工作区有该文件时，不论是否 `--add`，都不要 `git add`。先把工作区文件备份并挪走，让 `--only` 看到与 index 一致的缺失，提交删除，结束后放回。创建 commit 之前失败时，同一恢复把文件放回。

这不是现有的 blob 换入。index 里没有可写回的 blob。提交后的核对期待 HEAD 中没有该路径，而不是拿 blob 对比。

备选：`--add` 时提交工作区里后出现的文件。这会丢掉已经暂存的删除，和「index 有差异时提交 index」不一致。

### 4. rename 只在新路径也在参数里时放行

`git diff --cached -M` 仍把旧路径报成 rename，且新路径不在本次参数里时，`--add` 与不带 `--add` 都在创建 commit 之前退出。不提交删除，index 保持这次改名。新旧路径都在时，维持现在的 rename 提交，旧路径不执行 `git add`。

相似度下降、状态变成删除加新增时，旧路径不再走这条拒绝。它落进决策 2：两个路径都在则跳过旧路径的 `git add` 并提交删除加新增；只有旧路径则提交这次删除，新路径留在 index。

备选：凡是暂存删除都拒绝。那样 `git rm` 之后的 `--add` 也会失败。

### 5. copy 的旧路径不进 rename 跳过

rename 旧路径的判断只匹配 `R`，不匹配 `C`。copy 的旧路径仍在工作区与 index，按普通文件处理：有未暂存改动则换入 index，否则 `git add`。

备选：copy 也要求新旧路径一起出现。现有约定只对 rename 与 delete 要求成对路径，这次不扩大。

## Risks / Trade-offs

- [去重发生在第一次 `git add` 改了 index 之后，第二次才看到该换入] → 同一路径的两次判断在任何 `git add` 之前都看到调用前的 index。已进入 pending 的路径不再 `git add`。
- [挪走后出现的文件之后 hook 拒绝，文件回不来] → 失败恢复与成功恢复走同一份备份。提交后的 blob 核对不要把「HEAD 中没有该路径」判成换入失败。
- [只传旧路径时，相似度刚好卡在 rename 阈值两边，结果一个拒绝、一个提交删除] → 以当次 `git diff --cached -M` 为准，不另算相似度。规格里两条场景分开写。
- [PowerShell 把 `git add` 收成一次调用] → 去重和跳过都发生在路径进入待添加列表之前，不在 `git add` 之后补判。

## Migration Plan

只改两个入口脚本、`tests/check_scripts`、`troubleshooting.md`、`single-commit.md`、`batch-commit.md` 和 CHANGELOG。已有历史 commit 不改写。调用方不需要新参数。回滚是恢复这两个脚本。
