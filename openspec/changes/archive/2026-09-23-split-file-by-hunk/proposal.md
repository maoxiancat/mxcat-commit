## Why

`commit_one` 用 `git commit --only` 提交工作区里的整份文件。同一个文件里分属两条 commit 的改动会被合成一条，工作区被清空。路径自检只对照文件集合，两条都列出这个路径时也会通过，看不出内容被整份提交。

## What Changes

- batch 里同一个已跟踪文件可以出现在多条 commit 中。每条只提交属于它的 hunk。hunk 必须来自当时该文件相对当前 HEAD 的 diff。
- 非最后一段由 `commit_one` 做成「上一版加上这一段 hunk」的文件内容，备份工作区后临时放入并走现有 `--only`，无论成功或失败都把备份放回。文件已是 index 与工作区各一份、且 index 中的 blob 就是这一段时，直接用该 blob。
- 该文件在本计划中的最后一段若只要剩余全部改动，继续用现有 `--add`。其后 `git diff` 只剩未提交部分。若后面还有一段要再切，该段同样走部分提交。
- 预览必须写明每个共享路径在该条带走哪些 hunk。补丁对不上当时的 diff、二进制，或 rename 同时还要拆内容时，MUST 在创建该条 commit 之前停止，不得退回整文件提交。
- 部分提交成功后，除路径集合外，还要核对该文件在这条 commit 中的 diff 等于预览中的那些 hunk。
- agent 仍只调用当前 shell 的入口。不引入 agent 可直接使用的独立 index、shadow worktree、stash 或 `git add -p`。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 同一文件按 hunk 分次提交；部分提交后工作区保留剩余改动；自检核对 diff；无法安全拆分时停止。
- `mxcat-commit-preview-gate`: 同一路径可以出现在多条预览中，每条必须标明自己的 hunk；确认后该文件的 commit diff 必须等于这些 hunk。

## Impact

- 修改 `skills/mxcat-commit/scripts/commit_one` 与 `scripts/commit_one.ps1`，两边行为一致。
- 修改 `references/batch-commit.md` 的分组与第 5 步，以及 `references/troubleshooting.md`。`single-commit.md` 仍是整文件一条，不因同一文件含多段改动而拆开。
- `SKILL.md` 只在需要时用一句话指向入口的部分提交，不展开命令。
- 用临时仓库为部分提交、剩余段、失败放回备份补充测试。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该变更，不改写已发布版本条目正文。
