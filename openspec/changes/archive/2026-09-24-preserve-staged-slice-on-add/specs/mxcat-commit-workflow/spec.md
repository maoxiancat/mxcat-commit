## MODIFIED Requirements

### Requirement: 同一已跟踪文件 MUST 可按 hunk 分属多条 commit
batch 中同一个已跟踪文件 MUST 可以出现在多条 commit 里。每条 MUST 只包含预览为该条指定、且属于该文件相对当时 HEAD 的 diff 的 hunk。这些 hunk 在同一计划的各条之间 MUST NOT 重叠。部分提交返回后，该路径的工作区字节 MUST 与调用前一致；成功时该路径的 index blob MUST 等于刚创建的 commit，剩余 hunk MUST 仍以未暂存 diff 留在工作区。本计划中该文件的最后一段若只要剩余的全部改动，MUST 用整文件提交带走这些剩余 diff。其后仍要再切一段时，该段 MUST 再次按部分提交执行。single 在用户未同时要求只提交暂存区时，若该文件的 index 与 HEAD 相同或该文件尚未进入 index，MUST 把该文件的工作区全文写入这一条，MUST NOT 按 hunk 拆开。若该文件的 index 相对 HEAD 已有改动且工作区还有更多改动，这条 commit MUST 只含 index 中的模式与 blob，未暂存改动 MUST 留在工作区，MUST NOT 把该文件拆进多条 commit。

#### Scenario: 两条 commit 各取同一文件的一段
- **WHEN** batch 预览把同一已跟踪文件的两段不重叠 hunk 分给两条 commit，且用户已批准按序提交
- **THEN** 第一条 commit 中该文件的 diff MUST 只含分给它的 hunk
- **AND** 第一条返回后该文件的工作区字节 MUST 与提交前一致
- **AND** 第二条用整文件提交时，其 diff MUST 只含剩余 hunk

#### Scenario: 后面还有一段要再切
- **WHEN** 同一文件被分成三段，前两段都不是剩余全部
- **THEN** 前两段 MUST 各自只提交自己的 hunk
- **AND** 第三段 MUST 只包含当时仍留在工作区的该文件改动

#### Scenario: single 合为一条且只暂存了一截
- **WHEN** 用户要求合为一条，且未要求只提交暂存区，该文件的 index 相对 HEAD 已有改动，工作区还有更多改动
- **THEN** 该条 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 未暂存改动 MUST 仍出现在 `git diff` 中
- **AND** 技能 MUST NOT 把该文件拆进多条 commit

#### Scenario: single 合为一条且 index 与 HEAD 相同
- **WHEN** 用户要求合为一条，且未要求只提交暂存区，该文件的 index 与 HEAD 相同，工作区有未暂存改动
- **THEN** 该条 commit 中该文件 MUST 等于工作区全文
- **AND** 技能 MUST NOT 把该文件拆进多条 commit

### Requirement: 提交 MUST 锁预览路径
single 与 batch 在创建每条 commit 时，MUST 调用当前 shell 对应的入口，并把该条预览列出的仓库相对路径作为它的路径参数。当前 shell 是 sh、bash 或 zsh 时，入口 MUST 是技能目录中的 `scripts/commit_one`。当前 shell 是 Windows PowerShell 时，入口 MUST 是 `scripts/commit_one.ps1`。MUST NOT 在 PowerShell 中调用 `scripts/commit_one`，也 MUST NOT 在 sh 中调用 `scripts/commit_one.ps1`。下文的 `commit_one` 指这次实际调用的入口。该入口 MUST 把这些路径传给 `git commit --only`（或等价的「命令行给出路径」模式）。该 commit 的文件集合 MUST 等于这些路径，MUST NOT 把 index 中其它已暂存路径带进去。未列入该条的已暂存路径在提交后 MUST 仍留在 index。rename 或 delete 时，锁路径 MUST 包含该条预览列出的旧路径与新路径。默认输入为整棵工作树时，对 index 与 HEAD 相同或尚未进入 index 的整文件路径，`commit_one` MUST 先执行 `git add --`，以便纳入 untracked 与仅存在于工作区的改动。index 相对 HEAD 已有改动且工作区还有更多改动的路径，MUST NOT `git add` 工作区全文，MUST 提交 index 中的模式与 blob，未暂存改动 MUST 留在工作区。已暂存 rename 的旧路径已不在工作区、也不在 index 时，MUST NOT 对该旧路径执行 `git add --`；新旧路径都列入参数时，这条 commit MUST 是一次 rename。用户只要暂存区时，对整文件路径 MUST NOT `git add` 未暂存文件。被标为部分提交的已跟踪路径 MUST NOT 先 `git add` 工作区全文，MUST 提交由当前 HEAD 版本加上该条 hunk 得到的 blob；若 index 中该路径的 blob 已等于这个结果，MUST 改提交该 index blob。`commit_one` MUST NOT 因路径名像密钥、凭证或个人信息而拒绝参数中的路径。sh 与 PowerShell 入口 MUST 使用同一规则。

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

#### Scenario: 部分暂存时 --add 只提交 index 那一截
- **WHEN** `commit_one --add` 的路径里，某文件的 index 相对 HEAD 已有改动，工作区还有更多改动
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 调用返回后未暂存改动 MUST 仍出现在 `git diff` 中
- **AND** MUST NOT 把工作区全文写入该 commit

#### Scenario: 仅工作区有改动时 --add 仍提交全文
- **WHEN** `commit_one --add` 的路径尚未进入 index，或 index 与 HEAD 相同，且工作区有改动
- **THEN** 新建 commit 中该文件 MUST 等于工作区全文

#### Scenario: 已暂存的改名可以 --add 两个路径
- **WHEN** index 中已是 `old.txt -> new.txt`，且 `commit_one --add` 的路径同时包含旧路径与新路径
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit MUST 是一次 rename
- **AND** MUST NOT 因旧路径匹配不到文件而以非 0 退出
