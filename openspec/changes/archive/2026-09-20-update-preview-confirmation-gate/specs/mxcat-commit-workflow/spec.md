## MODIFIED Requirements

### Requirement: Batch 流程 MUST 预览整单后一次确认再按序提交
分批提交 MUST 由 agent 根据变更语义分组。整单预览在预览阶段得到批准后，技能 MUST 按预览顺序创建 commit。批准词遵循 preview-gate 的会话阶段规则。任一条创建失败时，MUST 停止后续提交并报告已成功与未成功的条目，MUST NOT 假装整单已完成，MUST NOT 运行 `git push`。

#### Scenario: 确认后按序提交
- **WHEN** 预览已出示且用户用「提交」「确认提交」或「帮我提交」批准了包含多条的整单预览
- **THEN** 技能 MUST 按预览顺序依次创建 commit
- **AND** 每条消息 MUST 与对应预览条目一致
- **AND** MUST NOT 运行 `git push`

#### Scenario: 中途失败停止
- **WHEN** 按序提交时某条 `git commit` 因 hook 或其他错误失败
- **THEN** 技能 MUST NOT 继续创建后续预览中的 commit
- **AND** MUST 向用户报告哪些条目已成功、哪一条失败、哪些尚未尝试
- **AND** MUST NOT 运行 `git push`

### Requirement: Batch 提交 MUST 使用常规 git 命令
本能力的分批提交 MUST 使用普通 git 命令完成暂存与提交。仅当用户在预览后批准「提交并 push」、且全部预定 commit 均已成功时，才 MUST 额外使用 `git push`。

#### Scenario: 用常规 git 命令提交
- **WHEN** agent 执行 batch 流程且用户只批准提交、未要求 push
- **THEN** 流程说明 MUST 使用 `git status`、`git diff`、`git add`、`git commit` 等常规命令
- **AND** MUST NOT 把 `git push` 列为该次必做步骤

#### Scenario: 提交并 push 时才加入 git push
- **WHEN** agent 执行 batch 或 single 流程且用户在预览后批准「提交并 push」，并且全部预定 commit 已成功
- **THEN** 流程说明 MUST 允许使用一次 `git push`
- **AND** MUST NOT 使用 `--force` 或 `--force-with-lease`

## ADDED Requirements

### Requirement: 批准提交并 push 后 MUST 在全部 commit 成功后再 push 一次
当用户在预览后说「提交并 push」时，技能 MUST 先按预览完成全部预定 `git commit`，然后对当前分支上游执行一次 `git push`。single 与 batch MUST 遵守同一顺序。技能 MUST NOT 在每条 commit 之后 push。技能 MUST NOT 使用 `--force` 或 `--force-with-lease`。没有上游时 MUST 报告原因并停止 push，MUST NOT 擅自 `git push -u`，已成功的 commit MUST 保留。用户只批准提交、未要求 push 时 MUST NOT 运行 `git push`。

#### Scenario: 全部分批成功后一次 push
- **WHEN** 预览含多条，用户回复「提交并 push」，且每条 `git commit` 均成功
- **THEN** 技能 MUST 在最后一条 commit 成功之后运行恰好一次 `git push`
- **AND** MUST NOT 在中间某条 commit 之后 push

#### Scenario: 单次提交成功后一次 push
- **WHEN** 当前为 single 预览且用户回复「提交并 push」，且该条 `git commit` 成功
- **THEN** 技能 MUST 随后运行恰好一次 `git push`

#### Scenario: commit 失败则不 push
- **WHEN** 用户回复「提交并 push」，但某条预定 `git commit` 失败
- **THEN** 技能 MUST NOT 运行 `git push`
- **AND** 已成功的 commit MUST 保留

#### Scenario: 无上游则报告且不擅自设上游
- **WHEN** 用户回复「提交并 push」，全部预定 commit 已成功，但当前分支没有上游
- **THEN** 技能 MUST 向用户报告无法 push 的原因
- **AND** MUST NOT 运行 `git push -u` 或 `--force`
- **AND** 已成功的 commit MUST 保留

### Requirement: 丢掉的预览条目 MUST 把文件留在工作区
当用户不要提交某一预览条目时，技能 MUST 只从预览计划中移除该条，MUST NOT 用 git 命令丢弃或还原该条列出的工作区改动。其余条目 MUST 作为新的整单预览再次等待批准。

#### Scenario: 丢掉一条后其余仍待确认
- **WHEN** 预览含多条且用户不要提交其中一条
- **THEN** 被丢掉条目的文件 MUST 仍出现在工作区未提交变更中
- **AND** 技能 MUST 对剩余条目重新出示预览
- **AND** MUST NOT 在同一次回复中提交剩余条目
