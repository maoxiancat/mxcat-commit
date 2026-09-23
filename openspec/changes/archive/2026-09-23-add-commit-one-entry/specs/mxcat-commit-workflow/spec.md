## MODIFIED Requirements

### Requirement: 提交 MUST 锁预览路径
single 与 batch 在创建每条 commit 时，MUST 调用当前 shell 对应的入口，并把该条预览列出的仓库相对路径作为它的路径参数。当前 shell 是 sh、bash 或 zsh 时，入口 MUST 是技能目录中的 `scripts/commit_one`。当前 shell 是 Windows PowerShell 时，入口 MUST 是 `scripts/commit_one.ps1`。MUST NOT 在 PowerShell 中调用 `scripts/commit_one`，也 MUST NOT 在 sh 中调用 `scripts/commit_one.ps1`。下文的 `commit_one` 指这次实际调用的入口。该入口 MUST 把这些路径传给 `git commit --only`（或等价的「命令行给出路径」模式）。该 commit 的文件集合 MUST 等于这些路径，MUST NOT 把 index 中其它已暂存路径带进去。未列入该条的已暂存路径在提交后 MUST 仍留在 index。rename 或 delete 时，锁路径 MUST 包含该条预览列出的旧路径与新路径。默认输入为整棵工作树时，`commit_one` MUST 先对这些路径执行 `git add --`，以便纳入 untracked；用户只要暂存区时 MUST NOT `git add` 未暂存文件。`commit_one` MUST NOT 因路径名像密钥、凭证或个人信息而拒绝参数中的路径。

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

### Requirement: 提交消息 MUST 来自本次命令的标准输入
single 与 batch 在创建每条 commit 时，消息 MUST 从本次 `commit_one` 的标准输入读入。产生消息的命令与该次 `commit_one` MUST 处于同一条管道。`commit_one` MUST 把这段消息交给同一次 `git commit --file -`，或交给只在该次进程内可见、结束即删除的消息来源后再提交。MUST NOT 把消息写入固定共享路径后再读取（包括 `/tmp/commit_msg.txt`）。header 与 body 之间需要空行时，消息生成 MUST 仍显式给出该空行。batch 每一条 MUST 使用自己的管道，MUST NOT 复用上一条的消息来源。

#### Scenario: 单次提交从标准输入读消息
- **WHEN** 用户已批准提交，且消息含标题、一个空行与 body
- **THEN** 技能 MUST 把该消息经本次管道送入 `commit_one`
- **AND** 新建 commit 的消息 MUST 等于这段输入
- **AND** MUST NOT 从固定共享路径读取消息

#### Scenario: 固定路径上已有另一段消息
- **WHEN** `/tmp/commit_msg.txt` 或其它固定共享路径上已有另一段消息，且用户已批准提交
- **THEN** `commit_one` MUST NOT 把该路径用作消息来源
- **AND** 新建 commit 的消息 MUST 等于本次标准输入

#### Scenario: batch 每条各自一条管道
- **WHEN** batch 按序创建两条 commit，且两条消息不同
- **THEN** 每条 MUST 各自调用一次 `commit_one`，并使用自己的标准输入管道
- **AND** 第二条 MUST NOT 复用第一条的消息来源

### Requirement: 提交后 MUST 对照预览路径自检文件集合
`commit_one` 在 `git commit` 成功后，MUST 用 `git show --name-only`（rename 则用 `--name-status`）核对新建 commit 的路径是否等于本次调用的路径参数。对不上时该次调用 MUST 非 0 退出，技能 MUST 视为自检失败：MUST 停止后续预定 commit，MUST 向用户报告实际路径与预览路径，MUST NOT 运行 `git push`，MUST NOT 输出成功回执，MUST NOT 自动 `reset` 已成功的 commit。

#### Scenario: 文件集合与预览一致
- **WHEN** 新建 commit 的路径与该次 `commit_one` 的路径参数一致
- **THEN** 技能 MUST 将本项自检视为通过
- **AND** 若其它自检也通过，可继续下一条或进入成功回执

#### Scenario: 文件集合与预览不一致则停止
- **WHEN** `git show` 列出的路径与该次 `commit_one` 的路径参数不一致
- **THEN** `commit_one` MUST 非 0 退出
- **AND** 技能 MUST 停止后续预定 commit
- **AND** MUST 报告实际路径与预览路径
- **AND** MUST NOT 运行 `git push`
- **AND** MUST NOT 使用成功回执开头
- **AND** 已成功的 commit MUST 保留

### Requirement: 只要暂存区且预览路径仍有未暂存改动时 MUST 停止
用户要求只提交暂存区时，`commit_one` MUST 在 `git commit` 之前检查该条路径参数是否还有 unstaged 改动（例如这些路径上的 `git diff` 非空）。若仍有，MUST 非 0 退出并说明无法在文件粒度下只提交该文件的 staged hunk，MUST NOT 对这些路径 `git add`，MUST NOT 创建该条 commit。

#### Scenario: 只要暂存区且预览路径工作区干净
- **WHEN** 用户只要暂存区，且该条预览路径没有 unstaged 改动
- **THEN** `commit_one` MUST 允许用 `--only` 锁这些路径提交
- **AND** MUST NOT 对这些路径再 `git add`

#### Scenario: 只要暂存区但预览路径有未暂存改动
- **WHEN** 用户只要暂存区，且该条预览路径上仍有 unstaged 改动
- **THEN** `commit_one` MUST 在创建 commit 之前停止
- **AND** MUST 说明无法只提交这些路径的 staged 部分
- **AND** MUST NOT 创建该条 commit
