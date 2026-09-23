## MODIFIED Requirements

### Requirement: Batch 提交 MUST 使用常规 git 命令
single 与 batch 的流程说明 MUST 按用途分三族授权 git 命令，MUST NOT 把授权写成封闭的 `git status`、`git diff`、`git add`、`git commit` 名单。三族为：分析、自检与回执使用只读查询（不改 index、不改 HEAD、不改工作区），至少包括 `git status`、`git diff`、`git log`、`git show`、`git cat-file`、`git remote get-url` 以及同等只读查询；写入仅限有门禁的 `git add`、`git commit` 与 `git push`；点名禁止 `--force` / `--force-with-lease`、擅自 `git push -u`、对丢掉预览文件的 `git restore` / `checkout` / `reset`、自动 `git reset` 已成功的 batch 条目、未确认 `git commit --amend`、独立 index、shadow worktree、rebase 与 stash。仅在以下情况才 MUST 额外使用 `git push`：用户在预览后批准「提交并 push」且全部预定 commit 均已成功；或本次预定 commit 已成功之后，用户明确要求 push。用户确认撤回已成功 commit 时，`git reset --soft` MUST 仅出现在故障恢复说明中，MUST NOT 列为常规写入。

#### Scenario: 用常规 git 命令提交
- **WHEN** agent 执行 batch 或 single 流程且用户只批准提交、未要求 push
- **THEN** 流程说明 MUST 允许该次使用写入族的 `git add` 与 `git commit`，以及只读查询
- **AND** MUST NOT 把 `git push` 列为该次必做步骤
- **AND** MUST NOT 把授权写成仅 `git status`、`git diff`、`git add`、`git commit`

#### Scenario: 提交并 push 时才加入 git push
- **WHEN** agent 执行 batch 或 single 流程且用户在预览后批准「提交并 push」，并且全部预定 commit 已成功
- **THEN** 流程说明 MUST 允许使用一次 `git push`
- **AND** MUST NOT 使用 `--force` 或 `--force-with-lease`

#### Scenario: 提交成功后再要求 push
- **WHEN** 预定 commit 已成功，用户当时只批准提交，随后明确要求 push（例如「帮我 push」「推一下」「git push」）
- **THEN** 流程说明 MUST 允许对当前分支上游执行一次 `git push`
- **AND** MUST NOT 使用 `--force` 或 `--force-with-lease`

#### Scenario: 自检与回执允许只读查询
- **WHEN** 技能做提交后自检或写成功回执
- **THEN** 流程说明 MUST 允许 `git log`、`git show`、`git cat-file`、`git status` 以及推导仓库地址所需的只读查询（例如 `git remote get-url`）
- **AND** MUST NOT 将这些命令视为超出授权

#### Scenario: 点名禁止的命令不得使用
- **WHEN** agent 执行 single 或 batch 流程
- **THEN** 流程说明 MUST NOT 授权 `--force` / `--force-with-lease`、擅自 `git push -u`、对丢掉预览文件的 `git restore` / `checkout` / `reset`、自动 `git reset` 已成功条目、未确认 amend、独立 index、shadow worktree、rebase 或 stash

#### Scenario: single 与 batch 使用同一套分族
- **WHEN** 技能同时提供 single 与 batch 流程说明
- **THEN** 两份说明顶部 MUST 使用同一套按用途分族的授权列表

#### Scenario: 撤回用的 reset 不属于常规写入
- **WHEN** 用户尚未明确要求撤回已成功的 commit
- **THEN** 流程说明 MUST NOT 把 `git reset --soft` 列为常规写入步骤
