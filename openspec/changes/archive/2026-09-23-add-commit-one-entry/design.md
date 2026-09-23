## Context

确认后的提交样例在 `references/single-commit.md` 与 `references/batch-commit.md`：agent 手写 `printf | git commit --file - --only -- <路径>`，成功后再 grep header、空行、禁页脚，并用 `git show` 对照路径。见 `proposal.md` 的 Why。`--only` 已经能挡住无关暂存文件；漏写时才会退回普通 `git commit`。密钥路径仍编进预览并提醒，这条不改。

## Goals / Non-Goals

**Goals:**

- 每条 commit 只有一个写入入口 `scripts/commit_one`，入口内部始终带 `--only`。
- header、分隔空行、禁页脚在 `git commit` 之前失败，且不创建该条 commit。
- 消息仍从本次调用的标准输入进入，不读固定共享路径。
- 只要暂存区时的未暂存改动硬停，以及提交后的路径对照，都由该入口退出码表达。

**Non-Goals:**

- 不引入批次执行器、plan 文件、独立 index、shadow worktree 或 secret scanner。
- 不按文件名排除密钥、凭证或个人信息。
- 不机械检查 subject 语言、emoji 语义、并列 scope 或 body 是否为 bullet。
- 不改预览门禁、固定收尾、分组规则或回执结构。
- 不把完整命令展开进 `SKILL.md`。

## Decisions

### Decision: 按 shell 选择入口，检查规则相同

`scripts/validate` 与 `scripts/commit_one` 给 sh、bash、zsh。`scripts/validate.ps1` 与 `scripts/commit_one.ps1` 给 Windows PowerShell。两边都只读本次消息，在 `git commit` 之前做同一套 header、空行和禁页脚检查。不增加 Python 依赖。

Alternatives considered:

- 只留 shell，让 Windows 用户改用 Git Bash：PowerShell 是 Windows 上 agent 的默认 shell，不会按 `#!/bin/sh` 执行无扩展名文件。
- 用 Python 一份脚本覆盖两边：安装环境不保证有 Python。

### Decision: 调用形如 `commit_one [--add] -- <路径…>`

默认整棵工作树时，agent 传入 `--add`。脚本先 `git add --` 这些路径，再 `git commit --file - --only --` 同一份路径。用户只要暂存区时不传 `--add`；这些路径上 `git diff` 非空则在 `git commit` 之前非 0 退出。

路径清单仍来自该条预览「改动部分」。脚本不知道预览全文，只保证「参数里的路径，且只有这些路径」进入 commit。rename / delete 的旧路径与新路径都由 agent 放进参数。

Alternatives considered:

- 脚本自己读预览 Markdown：要定计划文件格式，回到执行器。
- 继续让 agent 写 `--only`：漏写时没有入口可兜住。

### Decision: 消息留在本次进程里，不写固定路径

agent 的 `printf` 与本次 `commit_one` 是一条管道。脚本把标准输入收进仅本次进程使用的临时文件（`mktemp`，退出时删除），先交给 `validate`，通过后再 `git commit --file` 该文件。下一次调用不会看见这个文件。禁止读取或写入 `/tmp/commit_msg.txt` 这类固定路径。

`validate` 在文本上复现现行空行规则，不必先有 commit：第一行之后还有非空行时，标题段（到第一个空行）之后必须还有正文；只有标题则通过；多一个空行，或 body 与 `BREAKING CHANGE:` 之间缺空行，不因此失败。header 沿用现行自检：`^:[a-z0-9_+-]+: \([^)\s]+\)( !)? .+`。该正则会拒绝括号内空白，不会拒绝 `(auth,api)`；并列 scope 仍靠 agent 在分组时拆开。禁页脚匹配行首的 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:`、`Jira-Refs:`。

Alternatives considered:

- 用 shell 变量转存消息：尾部换行容易丢，空行规则会漂。
- 固定路径先删再写：删和写若拆开，中间仍可能提交残留内容。

### Decision: 路径对照失败时保留刚创建的 commit

`git commit` 成功后，脚本用 `git show --name-only --pretty=format:` 对照参数；rename 用 `--name-status`，旧路径与新路径都要在参数里。不一致则非 0 退出，不 `reset`。agent 见到非 0 就按现有中途失败处理：停下一条，不 push，不用成功回执。

### Decision: guide 按环境各留一条样例

`single-commit.md` / `batch-commit.md` 第 5 步：sh 用 `printf | scripts/commit_one --add -- <路径>`，Windows PowerShell 用 here-string 管道到 `powershell -File scripts/commit_one.ps1`。第 6 步不再让 agent 另跑四段 grep；非 0 即停。`troubleshooting.md` 把「自检失败」改成入口拒绝或路径对照失败。`SKILL.md` 用一句话指向这两个入口，不展开命令。

batch 仍是 agent 按预览顺序各调一次，每条一条管道。

## Risks / Trade-offs

- [Risk] agent 绕过脚本，直接 `git commit`。  
  Mitigation: 两份 guide 的可抄样例只有 `commit_one`；troubleshooting 写明不要另写 `git commit`。

- [Risk] 脚本里的临时文件在进程被杀死时残留。  
  Mitigation: 名字来自 `mktemp`，下次调用不会读它；正常退出由 trap 删除。

- [Risk] header 正则比「生成时不许并列 scope」更松。  
  Mitigation: 与现行自检对齐；并列 scope 仍是分组规则，不放进 `validate`。

- [Trade-off] 看过提醒后，`.env` 仍会随参数进入历史。  
  Mitigation: 这是现行预览规则；`commit_one` 不按文件名拒绝。

## Migration Plan

1. 添加 `scripts/validate` 与 `scripts/commit_one`，并在 `skills/mxcat-commit/tests/` 用临时仓库覆盖路径隔离、非法消息不创建 commit、只要暂存区时硬停。
2. 改 single / batch 第 5 步样例与第 6 步，以及 troubleshooting 的失败说明。
3. `SKILL.md` 加一句入口指向。`CHANGELOG.md` 记缺陷修复，不改已发布版本条目正文。
4. 回滚即去掉脚本与测试，并还原上述 markdown。

## Open Questions

无。
