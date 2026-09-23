## Context

确认后的提交只经 `scripts/commit_one` 或 `scripts/commit_one.ps1`。入口对路径执行 `git add`（带 `--add` 时）再 `git commit --only`。`--only` 提交的是这些路径的工作区全文。见 `proposal.md` 的 Why。路径集合自检因此看不出「同一文件被整份写进其中一条」。

## Goals / Non-Goals

**Goals:**

- 部分提交仍走同一次 `git commit --only`，其它已暂存路径不进入该 commit。
- 调用返回时，部分路径的工作区字节与调用前一致；成功时剩余改动留在未暂存 diff。
- sh 与 Windows PowerShell 的入口接受同一组参数，失败语义相同。
- 指定 hunk 对不上 `git diff HEAD`、二进制、rename 同时拆内容、或路径尚未进入 HEAD 时，在 `git commit` 之前退出。

**Non-Goals:**

- 不把独立 index、shadow worktree、stash 或 `git add -p` 交给 agent。
- 不拆二进制、不拆 rename/copy 的内容、不拆尚未进入 HEAD 的新文件。
- 不改 single 在「合为一条」且未要求只提交暂存区时提交工作区全文的行为。
- 不改预览固定收尾、消息来源和「不写固定共享路径」的规则。

## Decisions

### Decision: 先算出目标 blob，再短暂换入工作区，提交仍用 `--only`

部分路径的目标内容是「HEAD 版本加上该条 hunk」，或 index 里已经等于该结果的 blob。脚本把工作区文件备份后换上这份内容，对其余整文件路径照旧 `git add`，然后 `git commit --only --` 全部路径参数，最后恢复备份。`--only` 成功后会把该路径的 index 更新为刚提交的 blob；备份放回后，`git diff` 就是剩余 hunk。

换入期间 pre-commit 看到的是这一条的内容。`EXIT` 上无论 commit 成功、hook 失败还是自检失败，都恢复备份。

只用临时 index 从 HEAD 应用补丁并读出 blob。真正创建 commit 的仍是当前仓库上的 `--only`。agent 不设置 `GIT_INDEX_FILE`。

Alternatives considered:

- 用 `GIT_INDEX_FILE` 直接 `git commit`：hook 与 lint-staged 会看到另一份 index，真实 index 与 HEAD 脱节。
- `git add -p`：交互式，agent 无法稳定重放。
- 提交 index 且不带路径：其它已暂存文件会进入这条 commit。

### Decision: hunk 用本次调用专属的补丁文件传入

用法保持 `commit_one [--add] [--hunks <file>] -- <path>…`。`--hunks` 指向本次调用新建的补丁，不是 `/tmp/commit_msg.txt` 这类固定共享路径。补丁里出现的路径按部分提交；其余路径参数仍是整文件。消息继续只来自标准输入。

脚本把补丁应用到从 HEAD 建起的临时 index 上。应用失败，或补丁不是这些路径上 `git diff HEAD` 的完整 hunk 子集，就在替换工作区之前退出。index blob 已等于该结果时，可以不读补丁，直接使用 `:<path>`。

只要暂存区且不带 `--hunks`、路径仍有未暂存改动时：index 相对 HEAD 有差异则提交该 index blob；index 与 HEAD 相同则在 `git commit` 之前退出。这取代现在的「无法只提交 staged 部分」硬停。

Alternatives considered:

- 把补丁和消息共用标准输入：消息格式与补丁边界缠在一起，validate 无法只看消息。
- 只传 hunk 序号：预览之后 diff 一变，序号就指向另一段。

### Decision: 自检在路径集合之外核对 diff

路径集合仍用现有的 `git show --name-status`。带 `--hunks` 或走 index blob 的路径，再核对该文件在新建 commit 中的 diff 等于本次提交的 blob 相对其父版本的 diff。对不上就非 0 退出，不 `reset`，工作区已经按上一条决策恢复。

### Decision: 文档只让 batch 使用部分提交

`batch-commit.md` 写明：同一路径出现在多条时，非最后一段带 `--hunks`；最后一段若只要剩余全部，用现有 `--add`。`single-commit.md` 不增加 `--hunks` 样例。`SKILL.md` 最多一句指向入口，不展开命令。

## Risks / Trade-offs

- [Risk] hook 或 lint-staged 改写了换入后的工作区，commit 内容不再是指定 hunk。  
  Mitigation: 提交后对照 diff；不一致则非 0 退出并恢复工作区。已创建的 commit 保留，不自动 reset。

- [Risk] 进程在换入之后、恢复之前被杀死，工作区留下半份文件。  
  Mitigation: 备份与恢复放在 `EXIT` trap。无法覆盖 `SIGKILL`。

- [Risk] 预览之后工作区又变了，补丁不再是当前 diff 的子集。  
  Mitigation: 提交前重新对照 `git diff HEAD`，对不上就停，不退回整文件。

- [Trade-off] 同一文件的后一段依赖前一段已经进 HEAD。batch 必须按预览顺序执行，不能并行。

## Migration Plan

1. 给 `commit_one` 与 `commit_one.ps1` 加上 `--hunks` 与 index blob 路径，保留现有整文件 `--add`。
2. 在 `skills/mxcat-commit/tests/check_scripts` 覆盖部分提交、剩余段、补丁不匹配、只要暂存区的 index blob，以及失败时工作区字节不变。
3. 更新 `batch-commit.md` 与 `troubleshooting.md`。single 保持整文件一条。
4. 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文。
5. 回滚即还原上述脚本、测试与文档。
