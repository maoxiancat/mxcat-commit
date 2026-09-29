## Context

见 `proposal.md` 的 Why。shell 版在 `core.filemode=true` 时先 `chmod`，再 `git commit --only`。`--only` 从工作区重读该路径，能看见可执行位。`commit_one.ps1` 在文件不可执行时改为 `update-index --chmod=+x`，写的是当前 index。`git commit --only` 不用这份 index：它从 HEAD 拷出临时 index，再按工作区收录路径。`core.filemode` 不是 `true` 时，这次收录保持 HEAD 里的模式。

## Goals / Non-Goals

**Goals:**

- `core.filemode` 不是 `true` 时，换入条目的 `100644` / `100755` 原样进入 commit。
- 只改了模式、blob 与 HEAD 相同时，仍然创建 commit。
- 同一次 commit 里的其它路径、未点名的已暂存改动、失败时的 index 与工作区恢复，与现在的 `--only` 结果相同。
- 钩子仍由 `git commit` 执行。

**Non-Goals:**

- 不改 shell 版 `commit_one`。`core.filemode=true` 且工作区能表达该位时，PowerShell 仍走现在的 `git commit --only`。
- 不把符号链接改成 `cacheinfo`。`120000` 仍靠工作区里的链接让 `--only` 收录；建不起来时的失败与恢复保持现状。
- 不改说明读入、预览门禁、消息骨架。

## Decisions

### Decision: 模式表达不了时，提交一份写好 cacheinfo 的临时 index

先完成现在的换入，让提交进行时工作区字节与要提交的 blob 一致。若这次有待换入的普通文件，其模式与 HEAD 中该路径的模式不同，且 `core.filemode` 不是 `true`，则不再调用 `git commit --only`：

1. `GIT_INDEX_FILE` 指向临时 index，`git read-tree HEAD`。
2. 每个待换入条目：`update-index --cacheinfo <mode>,<blob>,<path>`；模式为 `absent` 时 `--force-remove`。
3. 本次路径参数里其余路径按工作区收录：文件在则加入，工作区已无该路径则从临时 index 删除。这样删除和改名与 `--only` 读工作区的结果相同。
4. 把 `GIT_WORK_TREE` 指到一个空目录，`checkout-index -a` 把这份临时 index 检出到那里，再执行 `git commit --file`，不带路径参数。不这样做时，`git commit` 会从真实工作区把本次没点名的已改文件也收进 commit。
5. 成功后清掉 `GIT_INDEX_FILE` 与 `GIT_WORK_TREE`。按临时 index 里这些路径的条目，写回真正的 index。其它路径不写。

`core.filemode` 不是 `true` 时，提交前的刷新会沿用 index 里已有的模式。cacheinfo 必须写在这次 `git commit` 之前，且内容与工作区字节一致，刷新才不会换成另一个 blob。

`Set-SwappedFileMode` 里的 `update-index --chmod=+x` 只服务于这条已被 `--only` 丢掉的 index，在 cacheinfo 路径上不再调用。`core.filemode=true` 时仍 `chmod` 后走 `--only`。

Alternatives considered:

- 继续 `--only`，只把 `chmod=+x` 提前或改到真实 index：`--only` 的临时 index 从 HEAD 重建，真实 index 上的模式进不了 commit。
- 提交时把 `core.filemode` 设为 `true`：Windows 上工作区没有可执行位，收录结果仍是 `100644`。
- `commit-tree` 再 `update-ref`：不跑 pre-commit、commit-msg、post-commit。

### Decision: 模式差异也算待换入，即使 git diff 是安静的

`core.filemode` 不是 `true` 时，`git diff --quiet` 不比较 `100644` 与 `100755`。index 与 HEAD 的模式或 blob 不同，就放入待换入列表，使用 index 里的模式和 blob。不得因为 diff 安静就留给 `--only`，也不得因此报「没有可提交的已暂存改动」。

`--add` 与不带 `--add` 都按此判断。index 与 HEAD 的模式和 blob 都相同、只是工作区还有改动时，仍按现在的规则提交工作区或拒绝，不把这种路径改成待换入。

Alternatives considered:

- 只在已经进入待换入列表的路径上改提交方式：只改了模式的路径今天进不了该列表，commit 仍不会创建。

## Risks / Trade-offs

- [Risk] 临时 index 上直接 `git commit` 时，真实工作区里没点名的已改文件会被一并提交。  
  Mitigation: 提交时把 `GIT_WORK_TREE` 指到检出了临时 index 的空目录。真实工作区仍按原样换入和恢复。

- [Risk] 临时 index 漏掉本次的删除或改名，树与现在的 `--only` 不一致。  
  Mitigation: 路径参数中不属于待换入 cacheinfo 的条目，按工作区有无决定加入或删除。改名仍由提交后的 `git show --name-status` 识别。

- [Risk] 成功后写回真实 index 时 `GIT_INDEX_FILE` 或 `GIT_WORK_TREE` 仍指向临时位置。  
  Mitigation: 提交一结束就清除这两个变量；`finally` 里再清一次，并删掉临时目录。未创建 commit 时仍用调用前的 index 备份恢复。

- [Risk] pre-commit 看到的是临时工作区，不是真实工作区里未纳入的改动。  
  Mitigation: 临时工作区等于即将提交的树。钩子仍由 `git commit` 执行。真实工作区在调用返回后恢复。

## Migration Plan

1. 改 `commit_one.ps1` 的待换入判断和提交步骤。
2. 在 `CHANGELOG.md` 顶部按现有条目格式记一笔。
3. 回滚即还原上述文件。不迁移已有 commit。
