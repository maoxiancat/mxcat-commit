## ADDED Requirements

### Requirement: 同一已跟踪文件 MUST 可按 hunk 分属多条 commit
batch 中同一个已跟踪文件 MUST 可以出现在多条 commit 里。每条 MUST 只包含预览为该条指定、且属于该文件相对当时 HEAD 的 diff 的 hunk。这些 hunk 在同一计划的各条之间 MUST NOT 重叠。部分提交返回后，该路径的工作区字节 MUST 与调用前一致；成功时该路径的 index blob MUST 等于刚创建的 commit，剩余 hunk MUST 仍以未暂存 diff 留在工作区。本计划中该文件的最后一段若只要剩余的全部改动，MUST 用整文件提交带走这些剩余 diff。其后仍要再切一段时，该段 MUST 再次按部分提交执行。single 在用户未同时要求只提交暂存区时，MUST 把该文件的工作区全文写入这一条，MUST NOT 按 hunk 拆开。

#### Scenario: 两条 commit 各取同一文件的一段
- **WHEN** batch 预览把同一已跟踪文件的两段不重叠 hunk 分给两条 commit，且用户已批准按序提交
- **THEN** 第一条 commit 中该文件的 diff MUST 只含分给它的 hunk
- **AND** 第一条返回后该文件的工作区字节 MUST 与提交前一致
- **AND** 第二条用整文件提交时，其 diff MUST 只含剩余 hunk

#### Scenario: 后面还有一段要再切
- **WHEN** 同一文件被分成三段，前两段都不是剩余全部
- **THEN** 前两段 MUST 各自只提交自己的 hunk
- **AND** 第三段 MUST 只包含当时仍留在工作区的该文件改动

#### Scenario: single 合为一条时提交工作区全文
- **WHEN** 用户要求合为一条，且未要求只提交暂存区，该文件同时有已暂存与未暂存改动
- **THEN** 该条 commit 中该文件 MUST 等于工作区全文
- **AND** 技能 MUST NOT 把该文件拆进多条 commit

### Requirement: 无法按 hunk 安全拆分时 MUST 停止
部分提交的 hunk 对不上该文件当时相对 HEAD 的 diff、该路径被 git 视为二进制、该路径是 rename 或 copy 且同时还要拆内容、或该路径尚未进入 HEAD 时，入口 MUST 在创建该条 commit 之前非 0 退出。MUST NOT 改成提交该文件的工作区全文。工作区字节 MUST 与调用前一致。技能 MUST 停止后续预定 commit，MUST NOT 运行 `git push`，MUST NOT 输出成功回执。

#### Scenario: hunk 对不上当前 diff
- **WHEN** 为某已跟踪文件指定的 hunk 不是该文件当时相对 HEAD 的 diff 的子集
- **THEN** 入口 MUST 在 `git commit` 之前退出
- **AND** MUST NOT 创建包含该文件工作区全文的 commit
- **AND** 该文件的工作区字节 MUST 保持不变

#### Scenario: 二进制或 rename 同时拆内容
- **WHEN** 要拆开的路径是二进制，或是 rename、copy 且还要按 hunk 拆内容
- **THEN** 入口 MUST 在创建该条 commit 之前退出
- **AND** MUST NOT 退回整文件提交

### Requirement: 部分提交后 MUST 核对该文件的 diff
部分提交的 `git commit` 成功后，入口 MUST 核对该文件在新建 commit 中的 diff 等于本次指定的 hunk。对不上时 MUST 非 0 退出。该 commit MUST 保留，MUST NOT 自动 `reset`。工作区字节仍 MUST 恢复为调用前的内容。技能 MUST 停止后续预定 commit，MUST NOT 运行 `git push`，MUST NOT 输出成功回执。

#### Scenario: diff 与指定 hunk 一致
- **WHEN** 部分提交成功，且该文件的 commit diff 等于本次指定的 hunk
- **THEN** 本项自检 MUST 通过
- **AND** 工作区中该文件 MUST 仍是调用前的字节

#### Scenario: diff 与指定 hunk 不一致
- **WHEN** 部分提交已经创建 commit，但该文件的 diff 不等于本次指定的 hunk
- **THEN** 入口 MUST 非 0 退出
- **AND** 已创建的 commit MUST 保留
- **AND** 工作区字节 MUST 恢复为调用前的内容
- **AND** 技能 MUST NOT 继续后续 commit，也 MUST NOT push

### Requirement: 只要暂存区且路径仍有未暂存改动时 MUST 只提交 index blob
用户要求只提交暂存区，且该条路径上仍有未暂存改动时，`commit_one` MUST 提交该路径在 index 中的 blob，MUST NOT `git add` 工作区全文，MUST NOT 把未暂存 hunk 写入该 commit。调用返回后工作区字节 MUST 与调用前一致，剩余改动 MUST 仍留在工作区。若该路径的 index blob 与 HEAD 相同，MUST 在创建 commit 之前退出，并说明没有可提交的已暂存改动。

#### Scenario: 已暂存的一半被提交
- **WHEN** 用户只要暂存区，该路径的 index 相对 HEAD 有改动，工作区还有更多改动
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 工作区字节 MUST 保持为调用前的内容
- **AND** 未暂存改动 MUST 仍出现在 `git diff` 中

#### Scenario: index 与 HEAD 相同
- **WHEN** 用户只要暂存区，该路径的未暂存 diff 非空，且 index blob 与 HEAD 相同
- **THEN** `commit_one` MUST 在创建 commit 之前退出
- **AND** MUST NOT 提交这些未暂存 hunk

## MODIFIED Requirements

### Requirement: 提交 MUST 锁预览路径
single 与 batch 在创建每条 commit 时，MUST 调用当前 shell 对应的入口，并把该条预览列出的仓库相对路径作为它的路径参数。当前 shell 是 sh、bash 或 zsh 时，入口 MUST 是技能目录中的 `scripts/commit_one`。当前 shell 是 Windows PowerShell 时，入口 MUST 是 `scripts/commit_one.ps1`。MUST NOT 在 PowerShell 中调用 `scripts/commit_one`，也 MUST NOT 在 sh 中调用 `scripts/commit_one.ps1`。下文的 `commit_one` 指这次实际调用的入口。该入口 MUST 把这些路径传给 `git commit --only`（或等价的「命令行给出路径」模式）。该 commit 的文件集合 MUST 等于这些路径，MUST NOT 把 index 中其它已暂存路径带进去。未列入该条的已暂存路径在提交后 MUST 仍留在 index。rename 或 delete 时，锁路径 MUST 包含该条预览列出的旧路径与新路径。默认输入为整棵工作树时，对整文件路径 `commit_one` MUST 先执行 `git add --`，以便纳入 untracked；用户只要暂存区时，对整文件路径 MUST NOT `git add` 未暂存文件。被标为部分提交的已跟踪路径 MUST NOT 先 `git add` 工作区全文，MUST 提交由当前 HEAD 版本加上该条 hunk 得到的 blob；若 index 中该路径的 blob 已等于这个结果，MUST 改提交该 index blob。`commit_one` MUST NOT 因路径名像密钥、凭证或个人信息而拒绝参数中的路径。

#### Scenario: 其它已暂存路径不进入本次 commit
- **WHEN** index 中除预览路径外还暂存了其它文件，且用户已批准按该预览经 `commit_one` 提交
- **THEN** 新建 commit 的文件集合 MUST 仅含该条预览列出的路径
- **AND** 那些未列入预览的已暂存路径 MUST 在提交后仍出现在 index 中

#### Scenario: 丢掉的预览条目即使仍暂存也不被吞入
- **WHEN** 用户不要提交某一预览条目，该条文件仍留在工作区且仍为 staged，随后用户批准经 `commit_one` 提交剩余条目
- **THEN** 剩余条目对应的 commit MUST NOT 包含被丢掉条目列出的路径

#### Scenario: batch 下一条仍只锁本条路径
- **WHEN** batch 预览含两条不同路径，第一条已经 `commit_one` 提交成功，第二条路径仍为 staged
- **THEN** 第二条 commit 的文件集合 MUST 仅含第二条预览列出的路径

#### Scenario: 参数中的密钥路径仍可提交
- **WHEN** 调用 `commit_one` 的路径参数包含尚未进入 HEAD 的 `.env`，且本次消息通过提交前检查
- **THEN** 新建 commit MUST 包含该 `.env` 路径
- **AND** `commit_one` MUST NOT 因该文件名拒绝提交

#### Scenario: sh 调用 shell 入口
- **WHEN** 当前 shell 是 sh、bash 或 zsh，且用户已批准提交
- **THEN** 技能 MUST 调用 `scripts/commit_one`
- **AND** MUST NOT 调用 `scripts/commit_one.ps1`

#### Scenario: Windows PowerShell 调用 ps1 入口
- **WHEN** 当前 shell 是 Windows PowerShell，且用户已批准提交
- **THEN** 技能 MUST 调用 `scripts/commit_one.ps1`
- **AND** MUST NOT 调用 `scripts/commit_one`

#### Scenario: 部分路径不提交工作区全文
- **WHEN** 某已跟踪路径被标为部分提交，且工作区里该文件还含有不属于这条的改动
- **THEN** 新建 commit 中该文件 MUST 只含这条的 hunk
- **AND** 调用返回后该文件的工作区字节 MUST 与调用前一致
- **AND** 同一次调用中的其它整文件路径 MUST 仍按整文件进入该 commit

## REMOVED Requirements

### Requirement: 只要暂存区且预览路径仍有未暂存改动时 MUST 停止
**Reason**: 只提交暂存区时，已暂存的 blob 就是这一条要的内容。停止会让这一半无法提交；`git commit --only` 又会把工作区里多出来的 hunk 一并写进 commit。
**Migration**: 改为「只要暂存区且路径仍有未暂存改动时 MUST 只提交 index blob」。index 中没有相对 HEAD 的改动时仍然停止，不得提交工作区里的未暂存 hunk。
