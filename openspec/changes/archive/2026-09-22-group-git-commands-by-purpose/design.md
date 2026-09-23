## Context

技能仍是文档约束 agent。`batch-commit.md` 开头把产品身份写成封闭四件套，自检与回执命令落在名单外。见 `proposal.md` 的 Why。不引入执行器仍是既有非目标；本次只改授权怎么写。

## Goals / Non-Goals

**Goals:**

- 两份 guide 顶部用同一套按用途分族的列表替换封闭名单。
- 只读族给得出例子，并允许同等只读，避免下次再漏 `git remote`。
- 禁止族点名，把操作禁令和产品身份（独立 index / shadow worktree）写在一起。

**Non-Goals:**

- 不改 `--only` 锁路径、预览门禁确认词、固定收尾或回执结构。
- 不把命令表展开进 `SKILL.md`。
- 不穷尽所有 git 子命令。

## Decisions

### Decision: 授权写成三族列表，不要封闭白名单

`batch-commit.md` 与 `single-commit.md` 顶部用同一份列表（可抄、两边同字）。保留各自后面那句确认前禁止 `git commit` / 未要求则不 push。

```markdown
按用途使用 git，不要当成封闭四件套。

分析、自检、回执（只读，不改 index / HEAD / 工作区）：
- `git status`
- `git diff`（含 `--cached`）
- `git log`
- `git show`
- `git cat-file`
- `git remote get-url`
- 以及同等只读查询

写入（有门禁）：
- `git add --` 该条预览路径（默认整棵工作树；只要暂存区则不要 add）
- `git commit --file` + `--only --` 同一份路径（预览已确认）
- `git push`（仅预览后「提交并 push」且全部预定 commit 成功，或提交成功后再说 push；不要 `--force`，没有上游不要擅自 `-u`）

禁止：
- `--force` / `--force-with-lease`
- 擅自 `git push -u`
- 丢掉的预览文件 `git restore` / `checkout` / `reset`
- 自动 `git reset` 已成功的 batch 条目
- 未确认 `git commit --amend`
- 独立 index、shadow worktree、rebase、stash
```

写入族只点门禁，不把第 5 步样例再抄一遍。

Alternatives considered:

- 补全白名单：`lock-commit-paths` 已经漏过一次；回执用的 `git remote get-url` 现在仍不在任何名单里。
- 「除禁止项外可用只读查询」、不给例子：agent 可能把 `stash` / `restore --staged` 当成查询。

### Decision: 「同等只读」以不改三处为准

只读 = 不改 index、不改 HEAD、不改工作区。新自检若只需再查一个只读子命令，不必改授权段。`git restore --staged`、`git switch`、`git stash` 会改三处之一，走禁止族。

### Decision: `git reset --soft` 只留在 troubleshooting

常规写入族不写 reset。`troubleshooting.md` 开头补一句：仅当用户明确要求撤回已成功的 commit 时，才允许 `git reset --soft`；不要从常规流程抄过来。现有「不要自动 reset」保留。

## Risks / Trade-offs

- [Risk] agent 仍把顶部列表当成封闭名单，不敢跑「同等只读」。  
  Mitigation: 只读族最后一项写成「以及同等只读查询」，并点明不改 index / HEAD / 工作区。

- [Risk] 禁止族与第 4 步确认表、troubleshooting 重复。  
  Mitigation: 顶部只点名；细节仍在原位。重复换授权清晰。

- [Trade-off] 顶部比现在的一句话长。  
  Mitigation: 三族列表仍短过把第 5、6、7 步命令再抄一遍；`SKILL.md` 不展开。

## Migration Plan

1. 用上面那份列表替换 `batch-commit.md` 开头「只用」句。
2. 把同一份列表写入 `single-commit.md` 顶部（确认前禁止那句之前）。
3. `troubleshooting.md` 补撤回才允许 `git reset --soft`。
4. CHANGELOG 记授权修正；不改已发布版本条目正文。
5. 回滚即还原上述 markdown。
