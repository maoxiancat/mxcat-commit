## MODIFIED Requirements

### Requirement: 主技能文档 SHALL 先完成 single 与 batch 路由
触发本技能后，默认加载层 MUST 先判断走单次还是分批，而不是先展开全部执行细节。默认 MUST 走 batch：按逻辑拆分未提交变更，输入为整棵工作树（staged + unstaged + untracked）。仅当用户明确要求合为一条 commit 时，MUST 走 single。工作区只剩 staged、用户未要求合为一条时，MUST 仍走 batch。用户说「只提交暂存区」但未要求合为一条时，MUST 仍走 batch，且输入收缩为 staged。

#### Scenario: 用户只说帮我提交
- **WHEN** 用户要求提交且未声明「合为一个 commit」
- **THEN** 技能 MUST 进入 batch 流程
- **AND** 输入范围 MUST 为整棵未提交工作树
- **AND** MUST 在生成分批预览前读取 batch 流程的按需说明

#### Scenario: 仅有 staged 改动且未要求合成一条
- **WHEN** `git status --short` 显示只剩 staged 变更，且用户未要求合为一条 commit
- **THEN** 技能 MUST 进入 batch 流程
- **AND** MUST 按逻辑拆分这些 staged 变更（若只有一组，预览标题 MUST 为 `## commit 1`）

#### Scenario: 存在未暂存或未跟踪改动
- **WHEN** 工作区存在 unstaged 或 untracked 改动，且用户未要求合为一条 commit
- **THEN** 技能 MUST 进入 batch 流程
- **AND** MUST 在生成分批预览前读取 batch 流程的按需说明

#### Scenario: 用户明确要求合为一条 commit
- **WHEN** 用户明确要求「合为一个 commit」或同等说法（如「合成一条」「不要拆」「就提交一条」）
- **THEN** 技能 MUST 走 single 流程
- **AND** 除非用户同时要求只提交暂存区，输入 MUST 为整棵未提交工作树

#### Scenario: 用户只要暂存区但仍要分批
- **WHEN** 用户明确要求只提交暂存区，且未要求合为一条 commit
- **THEN** 技能 MUST 走 batch 流程
- **AND** 输入 MUST 仅包含 staged 变更

### Requirement: Batch 提交 MUST 使用常规 git 命令
本能力的分批提交 MUST 使用普通 git 命令完成暂存与提交。仅在以下情况才 MUST 额外使用 `git push`：用户在预览后批准「提交并 push」且全部预定 commit 均已成功；或本次预定 commit 已成功之后，用户明确要求 push。

#### Scenario: 用常规 git 命令提交
- **WHEN** agent 执行 batch 流程且用户只批准提交、未要求 push
- **THEN** 流程说明 MUST 使用 `git status`、`git diff`、`git add`、`git commit` 等常规命令
- **AND** MUST NOT 把 `git push` 列为该次必做步骤

#### Scenario: 提交并 push 时才加入 git push
- **WHEN** agent 执行 batch 或 single 流程且用户在预览后批准「提交并 push」，并且全部预定 commit 已成功
- **THEN** 流程说明 MUST 允许使用一次 `git push`
- **AND** MUST NOT 使用 `--force` 或 `--force-with-lease`

#### Scenario: 提交成功后再要求 push
- **WHEN** 预定 commit 已成功，用户当时只批准提交，随后明确要求 push（例如「帮我 push」「推一下」「git push」）
- **THEN** 流程说明 MUST 允许对当前分支上游执行一次 `git push`
- **AND** MUST NOT 使用 `--force` 或 `--force-with-lease`

### Requirement: 批准提交并 push 后 MUST 在全部 commit 成功后再 push 一次
当用户在预览后说「提交并 push」时，技能 MUST 先按预览完成全部预定 `git commit`，然后对当前分支上游执行一次 `git push`。single 与 batch MUST 遵守同一顺序。技能 MUST NOT 在每条 commit 之后 push。技能 MUST NOT 使用 `--force` 或 `--force-with-lease`。没有上游时 MUST 报告原因并停止 push，MUST NOT 擅自 `git push -u`，已成功的 commit MUST 保留。用户在该次确认回复中只批准提交、未要求 push 时，该次回复 MUST NOT 运行 `git push`；其后用户明确要求 push 时，技能 MUST 允许一次 `git push`，并遵守同一条无 force、无擅自 `-u` 的约束。

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

#### Scenario: 只提交成功后再 push
- **WHEN** 用户曾只批准提交且预定 commit 已成功，随后明确要求 push，且当前分支有上游
- **THEN** 技能 MUST 运行恰好一次 `git push`
- **AND** MUST NOT 使用 `--force` 或 `--force-with-lease`

## ADDED Requirements

### Requirement: 提交或 push 成功后 MUST 输出对应回执
技能 MUST 按成功路径输出带槽位的中文回执，MUST NOT 在成功时临场改成另一种结构。每条本次新建的 commit MUST 使用如下三行（标签后为全角冒号）：`Commit：` 短 hash、`标题：` 完整 header、`变更：` 文件数、插入行数，以及括号内的简短人话摘要；若该 commit 有删除行，变更行 MUST 同时写出删除行数。多条新建 commit 时 MUST 按提交顺序重复这三行。`Commit：` 块只列出本次技能新建的 commit；分支行里「含 … 提交」MUST 列出这次 `git push` 实际送出的短 hash（可能包含更早未推送的 commit）。写「当前工作区应已无未提交变更」之前 MUST 查看 `git status`；若仍有未提交变更，MUST NOT 写这句，MUST 改为说明仍留在工作区的变更。commit 失败、push 失败或无上游时 MUST NOT 使用成功回执。

#### Scenario: 只提交成功
- **WHEN** 用户只批准提交，全部预定 commit 成功，且未在同一次回复中 push
- **THEN** 回执 MUST 以「提交已完成。」开头
- **AND** MUST 包含本次新建 commit 的 `Commit：` / `标题：` / `变更：` 块
- **AND** 若工作区已无未提交变更，MUST 写「当前工作区应已无未提交变更」
- **AND** 若存在 origin，MUST 邀请用户稍后 push（点到 owner/repo）
- **AND** MUST NOT 包含远程 / 分支 / 仓库地址这三行

#### Scenario: 提交并 push 都成功
- **WHEN** 用户批准「提交并 push」，全部预定 commit 成功，且 `git push` 成功
- **THEN** 回执 MUST 以「已提交并推送到 GitHub。」开头（origin 主机不是 GitHub 时 MUST 改为「已提交并推送到远程。」）
- **AND** MUST 包含本次新建 commit 的 `Commit：` / `标题：` / `变更：` 块
- **AND** MUST NOT 邀请用户再 push
- **AND** MUST 包含 `远程：` git URL、`分支：` 本地 → 上游（含实际送出的短 hash）、以及可推导时的 `仓库地址：` 网页 URL

#### Scenario: 提交之后再 push 成功
- **WHEN** 预定 commit 早已成功，用户随后要求 push，且 `git push` 成功
- **THEN** 回执 MUST 以「已推送到 GitHub。」开头（origin 主机不是 GitHub 时 MUST 改为「已推送到远程。」）
- **AND** MUST 包含 `远程：` / `分支：` / `仓库地址：`（可推导时）
- **AND** MUST NOT 再次列出本次新建 commit 的 `Commit：` 块

#### Scenario: 工作区仍有未提交变更
- **WHEN** 预定 commit 成功，但 `git status` 仍显示未提交变更（例如丢掉的预览条目留在工作区）
- **THEN** 回执 MUST NOT 写「当前工作区应已无未提交变更」
- **AND** MUST 说明仍有未提交变更

#### Scenario: 新建一条但 push 送出两条
- **WHEN** 本次技能只新建一条 commit，且这次 `git push` 还送出了更早未推送的 commit
- **THEN** `Commit：` 块 MUST 只列出本次新建的那一条
- **AND** 分支行 MUST 列出这次实际送出的全部短 hash
