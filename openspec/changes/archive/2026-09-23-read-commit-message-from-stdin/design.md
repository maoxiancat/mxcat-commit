## Context

技能仍是文档约束 agent。确认后按 `references/single-commit.md` / `references/batch-commit.md` 第 5 步样例执行 `git add` 与 `git commit`。见 `proposal.md` 的 Why。样例现在把消息写到 `/tmp/commit_msg.txt`。不引入执行器仍是既有非目标；本次只改消息怎么送进 `git commit --file`。

## Goals / Non-Goals

**Goals:**

- 样例里消息与本次 `git commit` 绑在同一条管道，读端是 `--file -`。
- 空行继续用 `printf` 的 `''` 显式写出，agent 抄样例时看得到那一行。
- batch 每条各自一条管道。

**Non-Goals:**

- 不改 header、body、footer 的生成规则，也不改空行自检。
- 不改成多个 `-m`，不用 heredoc 把空行藏进不可见的空行。
- 不引入 `mktemp`、固定路径的清理脚本，或消息文件残留检查。
- 不把命令展开进 `SKILL.md` 或 `commit-convention.md`。

## Decisions

### Decision: `printf` 管道进 `git commit --file -`

同一条管道里，消息只存在于这次进程的标准输入。`printf` 没跑成时，git 读到空消息并拒绝提交，不会退回去读上次留下的文件。`git add` 仍写在管道之前，路径锁（`--only --`）不变。

在 git 2.50.1 上，这条管道与 `--only -- <路径>` 一起用时，标题与正文之间的空行和正文里的反引号都还在。会把标准输入读光的 pre-commit hook 拿到 0 字节；`commit-msg` 读的是 `.git/COMMIT_EDITMSG`。

Alternatives considered:

- `mktemp` 再 `--file`：并行安全，但要让 shell 变量活过写入和提交，还要删除。复用同一个文件时，第二次 `printf` 失败仍可能提交旧内容。
- 继续固定路径、只改成每次先删再写：删和写拆成两次调用时，中间仍可能提交残留文件。

### Decision: 保留 `printf '%s\n'` 与显式 `''`

空行必须在样例里是一个看得见的参数。heredoc 里的空行容易在抄写时丢掉，多个 `-m` 会在 bullet 之间多插空行，反引号也更容易被 shell 吃掉。

Alternatives considered:

- `git commit -m` / 多个 `-m`：和「空行被吃掉时多半是用了多个 `-m`」的现有故障说明对着干。

### Decision: batch 每条一块管道，不共享消息来源

第 5 步按序对每条重复「`git add`，然后 `printf | git commit --file -`」。不设跨条目的消息文件或变量。

## Risks / Trade-offs

- [Risk] agent 把 `printf` 和 `git commit --file -` 拆成两次调用，第二次标准输入为空。  
  Mitigation: 样例写成一条管道；空消息会被 git 拒绝，不会提交别的文件里的旧消息。

- [Risk] 个别 hook 依赖 `git commit` 的原始标准输入。  
  Mitigation: 已核对 pre-commit 读标准输入时消息仍完整；`commit-msg` 使用消息文件。若某仓库的 hook 必须读用户标准输入，这次提交会失败并停，已成功的 commit 仍保留。

- [Trade-off] 失败时没有消息文件可以再 `cat`。  
  Mitigation: 消息就在刚执行的命令里；提交成功后用现有 `git log` 自检。

## Migration Plan

1. 改 single 第 5 步两处样例为 `printf | git commit --file - --only --`。
2. 改 batch 第 5 步样例，并写明每条各自一条管道。
3. troubleshooting 重写消息处补一句：不要写到固定路径。
4. CHANGELOG 记缺陷修复；不改已发布版本条目正文。
5. 回滚即还原上述 markdown。
