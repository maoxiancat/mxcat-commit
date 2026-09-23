## Context

技能仍是文档约束 agent：确认后按 `references/single-commit.md` / `references/batch-commit.md` 第 5 步样例执行 `git add` + `git commit --file`。见 `proposal.md` 的 Why。不引入执行器是既有非目标；本次只改推荐命令、自检和混合暂存护栏。

## Goals / Non-Goals

**Goals:**

- 把「锁路径」写进两份 guide 的可抄样例，使 `git commit` 只含该条预览路径。
- 自检从只看消息，补上 `git show` 对照预览路径。
- 只要暂存区且预览路径仍有 unstaged 时硬停，避免 `--only` 吃进工作区多余 hunk。

**Non-Goals:**

- 不引入批次执行器、独立 index、shadow worktree、inventory / plan JSON。
- 不改失败留下已成功 commit、不自动 reset、不 force push。
- 不做 hunk 级拆分。
- 不把完整命令展开进 `SKILL.md`。

## Decisions

### Decision: 用 `git commit --only -- <预览路径>` 锁文件集合

官方语义：`--only` 用命令行这些路径的工作区内容做 commit，无视其它已暂存路径；提交后那些路径仍留在 index。有路径时这本是默认模式，样例仍显式写 `--only`，避免 agent 以为有 `--file` 就不必给路径。

`add` 仍保留在默认整棵工作树路径上，因为 untracked 必须先被认识；锁是 `--only` 后的路径清单，与该条预览反引号路径同一份。rename / delete 要旧路径和新路径都写进清单。

Alternatives considered:

- 清空 index 再 add：会拆掉用户的暂存和 `add -p`，也和「丢掉条目不要 reset」打架。

### Decision: 路径清单来自该条预览「改动部分」

解释里每个文件已要求仓库相对路径 + 反引号。提交与自检共用这份清单，不再另造 plan 文件。跳过预览时，清单是该条实际要提交的路径。

Alternatives considered:

- 另写 `/tmp/plan.json`：超出文档约束范围。
- 只锁 `git add` 过的路径、不对照预览：预览漏列或 add 多列时没有闭门。

### Decision: 自检对照 `git show --name-only`，rename 用 `--name-status`

消息自检过了仍可能文件集合错（漏写 `--only`）。对不上走现有中途失败，`troubleshooting.md` 加一节即可。

Alternatives considered:

- 只改样例、不加自检：agent 仍可能抄漏 `--only`。
- 用 `git show --stat` 肉眼看回执：回执在自检通过之后，拦不住错误成功回执。

### Decision: 只要暂存区且这些路径 `git diff` 非空则停止

`--only` 吃工作区。默认整棵工作树就要工作区，没有这个问题。只要暂存区时，工作区多出来的 hunk 不能进 commit；无执行器也做不了 hunk 拆。硬停比悄悄交错或 `reset` 更安全。

Alternatives considered:

- 只要暂存区仍 `--only`：会把 unstaged 带进去。
- 恢复独立 index 只提交 index blob：回到执行器。

## Risks / Trade-offs

- [Risk] agent 仍漏写 `--only` 或锁错路径。  
  Mitigation: 样例把 `--only --` 和路径写在同一条命令里；自检对不上就停。

- [Risk] 预览漏列 rename 旧路径，commit 变成「只加新文件」。  
  Mitigation: guide 写明 rename / delete 要把预览里的旧路径和新路径都列入锁清单。

- [Risk] 只要暂存区的混合文件变常见，硬停显得无能。  
  Mitigation: 明确这是文件粒度的已知边界；hunk 拆仍是非目标。

- [Trade-off] 文档约束挡不住所有 agent 走神。  
  Mitigation: 接受与既有预览门禁同一层次的风险；本次不为此引入脚本。

## Migration Plan

1. 改 single / batch 第 5 步样例与文字：`git add --` + `git commit --file --only --`。
2. 改第 6 步自检，并在 troubleshooting 写路径对不上。
3. 只要暂存区的混合文件护栏写进两份 guide。
4. CHANGELOG 记缺陷修复；不改已发布版本条目正文。
5. 回滚即还原上述 markdown。
