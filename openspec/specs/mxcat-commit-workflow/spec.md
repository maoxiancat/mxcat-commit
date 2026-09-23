# mxcat-commit-workflow Specification

## Purpose

定义 `mxcat-commit` 如何在默认加载层完成 single / batch 分流，如何按读取时机展开 reference，以及无脚本分批提交时必须遵守的流程边界。

## Requirements

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

### Requirement: 主技能文档 SHALL 将细节延迟到按需引用层
`SKILL.md` MUST 保留分流规则、预览门禁摘要和消息硬约束摘要，并把 single 执行细节、batch 分组细节、完整 emoji 类型表和故障排查放到 `references/`。主文档 MUST 明确写出何时读取哪份 reference。

#### Scenario: 首次读取主文档
- **WHEN** agent 因触发词加载 `SKILL.md`
- **THEN** 该文档 MUST 说明 single 与 batch 的分流条件
- **AND** MUST 摘要预览确认门禁
- **AND** MUST 摘要 header / 默认中文 / 禁止 AI trailer 与 Jira 页脚
- **AND** MUST 用表格或等价形式指出各 reference 的读取时机

#### Scenario: 需要完整 emoji 类型表
- **WHEN** 当前变更属于依赖的升级、降级、移除或锁版本，或只改文案与字面量，或属于 CI，或属于国际化
- **THEN** 技能 MUST 读取类型表 reference，并从该表选择 shortcode
- **AND** 默认加载层 MUST NOT 要求预先展开完整类型表

#### Scenario: 读取时机写明这些场合
- **WHEN** agent 读取主文档的 reference 表
- **THEN** 完整类型表的读取时机 MUST 点明依赖升级或移除、只改文案、CI 与国际化
- **AND** MUST NOT 把读取时机只写成「常用类型不足以覆盖当前语义」

### Requirement: Batch 流程 MUST 预览整单后一次确认再按序提交
分批提交 MUST 由 agent 根据变更语义分组。整单预览在预览阶段得到批准后，技能 MUST 按预览顺序创建被批准的 commit。批准范围可以是整单，也可以是 preview-gate 约定的点名子集。批准词遵循 preview-gate 的会话阶段规则。任一条创建失败时，MUST 停止后续提交并报告已成功与未成功的条目，MUST NOT 假装整单或该子集已完成，MUST NOT 运行 `git push`。

#### Scenario: 确认后按序提交
- **WHEN** 预览已出示且用户用独立的「提交」批准了包含多条的整单预览
- **THEN** 技能 MUST 按预览顺序依次创建 commit
- **AND** 每条消息 MUST 与对应预览条目一致
- **AND** MUST NOT 运行 `git push`

#### Scenario: 子集确认后按原序只提交被点名的条
- **WHEN** 预览已出示且用户点名只提交其中部分条目
- **THEN** 技能 MUST 按预览原序只创建被点名的那些 commit
- **AND** MUST NOT 创建未被点名的条目
- **AND** 未被点名条目列出的文件 MUST 仍留在工作区

#### Scenario: 中途失败停止
- **WHEN** 按序提交时某条 `git commit` 因 hook 或其他错误失败
- **THEN** 技能 MUST NOT 继续创建后续预览中的 commit
- **AND** MUST 向用户报告哪些条目已成功、哪一条失败、哪些尚未尝试
- **AND** MUST NOT 运行 `git push`

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

### Requirement: 提交或 push 成功后 MUST 输出对应回执
技能 MUST 按成功路径输出带槽位的中文回执，MUST NOT 在成功时临场改成另一种结构。每条本次新建的 commit MUST 使用如下三行（标签后为全角冒号）：`Commit：` 短 hash、`标题：` 完整 header、`变更：` 文件数、插入行数，以及括号内的简短人话摘要；若该 commit 有删除行，变更行 MUST 同时写出删除行数。多条新建 commit 时 MUST 按提交顺序重复这三行。`Commit：` / `标题：` / `变更：` 同一组内 MUST 输出为 Markdown 无序列表（每项以 `- ` 起头），MUST NOT 用空行分隔组内各项。`分支：` / `仓库地址：` MUST 遵守同一规则。组与组之间 MUST 空一行。回执开头句与工作区句 MUST 保持普通段落，MUST NOT 写成列表项。`Commit：` 块只列出本次技能新建的 commit；分支行里「含 … 提交」MUST 列出这次 `git push` 实际送出的短 hash（可能包含更早未推送的 commit）。写「当前工作区应已无未提交变更」之前 MUST 查看 `git status`；若仍有未提交变更，MUST NOT 写这句，MUST 改为说明仍留在工作区的变更。commit 失败、push 失败或无上游时 MUST NOT 使用成功回执。

#### Scenario: 只提交成功
- **WHEN** 用户只批准提交，全部预定 commit 成功，且未在同一次回复中 push
- **THEN** 回执 MUST 以「提交已完成。」开头
- **AND** MUST 包含本次新建 commit 的 `Commit：` / `标题：` / `变更：` 块
- **AND** 若工作区已无未提交变更，MUST 写「当前工作区应已无未提交变更」
- **AND** 若存在 origin，MUST 邀请用户稍后 push（点到 owner/repo）
- **AND** MUST NOT 包含 `分支：` / `仓库地址：` 块

#### Scenario: 提交并 push 都成功
- **WHEN** 用户批准「提交并 push」，全部预定 commit 成功，且 `git push` 成功
- **THEN** 回执 MUST 以「已提交并推送到 GitHub。」开头（origin 主机不是 GitHub 时 MUST 改为「已提交并推送到远程。」）
- **AND** MUST 包含本次新建 commit 的 `Commit：` / `标题：` / `变更：` 块
- **AND** MUST NOT 邀请用户再 push
- **AND** MUST 包含 `分支：` 本地 → 上游（含实际送出的短 hash），以及可推导时的 `仓库地址：` 网页 URL

#### Scenario: 提交之后再 push 成功
- **WHEN** 预定 commit 早已成功，用户随后要求 push，且 `git push` 成功
- **THEN** 回执 MUST 以「已推送到 GitHub。」开头（origin 主机不是 GitHub 时 MUST 改为「已推送到远程。」）
- **AND** MUST 包含 `分支：`；可推导时 MUST 包含 `仓库地址：`
- **AND** MUST NOT 再次列出本次新建 commit 的 `Commit：` 块

#### Scenario: 工作区仍有未提交变更
- **WHEN** 预定 commit 成功，但 `git status` 仍显示未提交变更（例如丢掉的预览条目留在工作区）
- **THEN** 回执 MUST NOT 写「当前工作区应已无未提交变更」
- **AND** MUST 说明仍有未提交变更

#### Scenario: 新建一条但 push 送出两条
- **WHEN** 本次技能只新建一条 commit，且这次 `git push` 还送出了更早未推送的 commit
- **THEN** `Commit：` 块 MUST 只列出本次新建的那一条
- **AND** 分支行 MUST 列出这次实际送出的全部短 hash

#### Scenario: 回执字段组内用 Markdown 列表
- **WHEN** 技能输出 Commit 块或 `分支：` / `仓库地址：` 块
- **THEN** 组内各项 MUST 各为一行无序列表项（以 `- ` 起头）
- **AND** 组内各项 MUST 紧邻，中间 MUST NOT 空行
- **AND** 回执开头句与工作区句 MUST NOT 写成列表项

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

### Requirement: 丢掉的预览条目 MUST 把文件留在工作区
当用户不要提交某一预览条目时，技能 MUST 只从预览计划中移除该条，MUST NOT 用 git 命令丢弃或还原该条列出的工作区改动。若该句没有用独立的「提交」批准剩余条目，其余条目 MUST 作为新的整单预览再次等待批准。若该句同时批准剩余条目，技能 MUST 按 preview-gate 的子集规则当场提交剩余条，MUST NOT 再出一轮剩余预览等待。

#### Scenario: 丢掉一条后其余仍待确认
- **WHEN** 预览含多条且用户不要提交其中一条，且该句没有批准剩余条目
- **THEN** 被丢掉条目的文件 MUST 仍出现在工作区未提交变更中
- **AND** 技能 MUST 对剩余条目重新出示预览
- **AND** MUST NOT 在同一次回复中提交剩余条目

#### Scenario: 丢掉同时批准剩余则不重出再等
- **WHEN** 预览含多条且用户不要提交其中一条，同一句还用独立的「提交」批准剩余条目
- **THEN** 被丢掉条目的文件 MUST 仍出现在工作区未提交变更中
- **AND** 技能 MUST 按原序创建剩余条目
- **AND** MUST NOT 再对剩余条目出示预览等待

### Requirement: 尚未进入 HEAD 的密钥与个人信息 MUST 仍编进预览
single 与 batch 在分组时，若某路径明显是密钥、凭证或个人信息，且该路径尚未出现在 HEAD 中（未跟踪或已暂存但从未提交），技能 MUST 仍把它写入某条预览的「改动部分」。技能 MUST NOT 使用硬编码文件名名单来决定排除或纳入。技能 MUST NOT 仅因这类路径而停止预览或拒绝创建条目。已在 HEAD 中的同名路径之修改 MUST NOT 仅因此被特殊处理。

#### Scenario: 未跟踪的 .env 仍编进预览
- **WHEN** 输入范围内存在未跟踪的 `.env`，且还有业务文件
- **THEN** 某条预览的「改动部分」MUST 包含该 `.env` 路径

#### Scenario: staged 新增的密钥仍编进预览
- **WHEN** 输入范围内存在已暂存、但 HEAD 中尚不存在的 `id_rsa` 或通讯录 csv 等明显密钥或个人信息路径
- **THEN** 某条预览的「改动部分」MUST 包含这些路径

#### Scenario: 已跟踪文件的修改不因该规则改变分组
- **WHEN** 某明显密钥路径已存在于 HEAD，本次输入只是该路径的修改
- **THEN** 技能 MUST NOT 仅因本规则把它从预览中拿掉或停止预览

### Requirement: `.agents/skills/*` 默认 MUST 与业务代码拆成不同预览条目
当输入范围内同时存在 `.agents/skills/` 下的路径与之外的业务路径时，技能 MUST 把 `.agents/skills/*` 编进与业务代码不同的预览条目。用户明确要求将它们与业务代码合并时，技能 MUST 允许合并。用户明确要求合为一条 commit 时，该要求视为允许将 skills 与业务写入同一条。

#### Scenario: skills 与业务同时存在时默认分开
- **WHEN** 输入范围内既有 `src/` 下的业务改动，也有 `.agents/skills/` 下的改动，且用户未要求合为一条或合并这些文件
- **THEN** 预览 MUST 至少包含一条只含 `.agents/skills/*` 路径的条目
- **AND** 业务路径 MUST NOT 出现在该条的「改动部分」

#### Scenario: 用户要求合为一条时允许混入 skills
- **WHEN** 用户明确要求合为一个 commit，且输入范围内同时有业务路径与 `.agents/skills/*`
- **THEN** 技能 MUST 允许把它们写入同一条预览

### Requirement: git 视为 binary 的路径默认 MUST 不与功能文件写在同一条
当 git 将某路径视为 binary（例如 `git diff --numstat` 对该路径显示 `-	-`），且输入范围内还有非 binary 的功能文件时，技能 MUST 把该 binary 路径编进与功能文件不同的预览条目，并在该条解释中点名这是二进制。用户明确要求合并或合为一条 commit 时，技能 MUST 允许将 binary 与功能文件写入同一条。

#### Scenario: 二进制与功能文件默认拆开
- **WHEN** 输入范围内同时存在非 binary 的功能文件与 git 视为 binary 的未跟踪或已修改文件，且用户未要求合并或合为一条
- **THEN** 预览 MUST 把 binary 路径放在与功能文件不同的条目中
- **AND** 该条解释 MUST 点名这是二进制

#### Scenario: 用户要求合为一条时允许混入二进制
- **WHEN** 用户明确要求合为一个 commit，且输入范围内同时有功能文件与 binary 路径
- **THEN** 技能 MUST 允许把它们写入同一条预览
