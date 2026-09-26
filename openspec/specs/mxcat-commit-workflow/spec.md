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
用户要求只提交暂存区，且该条路径上仍有未暂存改动时，`commit_one` MUST 提交该路径在 index 中的模式与 blob，MUST NOT `git add` 工作区全文，MUST NOT 把未暂存 hunk 写入该 commit。新建 commit 中该路径的类型与模式 MUST 等于 index 中的条目。调用返回后该路径的工作区内容与路径类型 MUST 与调用前一致，剩余改动 MUST 仍留在工作区。若该路径在 index 中的模式与 blob 都与 HEAD 相同，MUST 在创建 commit 之前退出，并说明没有可提交的已暂存改动。只改了模式、blob 与 HEAD 相同时，MUST 提交这个模式，MUST NOT 以没有已暂存改动为由退出。同一次调用还带 `--hunks` 时，未出现在该补丁中的路径 MUST 仍遵守本要求，MUST NOT 把这些路径的未暂存内容写入该 commit；补丁中的路径 MUST 仍只提交选中 hunk 对应的条目。当前目录不是仓库根时，本要求 MUST 与在仓库根调用时相同。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 已暂存的一半被提交
- **WHEN** 用户只要暂存区，该路径的 index 相对 HEAD 有改动，工作区还有更多改动
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 工作区字节 MUST 保持为调用前的内容
- **AND** 未暂存改动 MUST 仍出现在 `git diff` 中

#### Scenario: index 与 HEAD 相同
- **WHEN** 用户只要暂存区，该路径的未暂存 diff 非空，且 index 的模式与 blob 都与 HEAD 相同
- **THEN** `commit_one` MUST 在创建 commit 之前退出
- **AND** MUST NOT 提交这些未暂存 hunk

#### Scenario: 只暂存了可执行位
- **WHEN** 用户只要暂存区，index 中该路径为 `100755`，blob 与 HEAD 相同，工作区另有内容改动
- **THEN** 新建 commit 中该路径 MUST 为 `100755`，blob MUST 与 HEAD 相同
- **AND** 工作区内容 MUST 与调用前一致
- **AND** MUST NOT 把未暂存的内容改动写入该 commit

#### Scenario: hunks 旁路的已暂存文件
- **WHEN** 同一次调用用 `--hunks` 只提交路径 A 的一段 hunk，路径 C 不在该补丁中，且不带 `--add`
- **AND** C 的 index 相对 HEAD 有改动，工作区在这之上还有未暂存改动
- **THEN** 新建 commit 中 A MUST 只含选中的 hunk
- **AND** 新建 commit 中 C 的 diff MUST 等于 C 的 index 相对 HEAD 的 diff
- **AND** C 的未暂存改动 MUST 仍留在工作区
- **AND** A 的未选中 hunk MUST 仍留在工作区

#### Scenario: hunks 旁路但 index 与 HEAD 相同
- **WHEN** 同一次调用用 `--hunks` 提交其它路径的一段合法 hunk，且不带 `--add`
- **AND** 另一参数路径的未暂存 diff 非空，其 index 的模式与 blob 都与 HEAD 相同
- **THEN** `commit_one` MUST 在创建 commit 之前退出
- **AND** MUST NOT 把该路径的未暂存内容写入 commit

#### Scenario: 子目录中只提交已暂存内容
- **WHEN** 当前目录不是仓库根，路径参数相对该当前目录
- **AND** 用户只要暂存区，该路径的 index 相对 HEAD 有改动，工作区还有更多改动
- **THEN** 该次调用 MUST 创建 commit
- **AND** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 工作区字节 MUST 保持为调用前的内容

### Requirement: 换入提交 MUST 保持路径类型且不丢未选改动
按 hunk 提交，或不带 `--add` 提交 index 内容时，`commit_one` MUST 把要提交的模式与 blob 写入该次 commit。`100644` 与 `100755` MUST 保持对应模式。`120000` MUST 作为符号链接提交，链接目标 MUST 等于该 blob 的内容。调用返回后，该路径的工作区字节与路径类型 MUST 与调用前一致。同一路径在一次补丁里出现多个 `diff --git` 头时，MUST 只按该路径换入一次，未纳入的 hunk MUST 仍留在工作区。一次调用的路径参数折成同一仓库相对路径时，不论写法是否相同，MUST 只按该路径换入一次，恢复 MUST 用调用前的那一份。当前目录不是仓库根时，按 hunk 换入 MUST 与在仓库根调用时相同，MUST NOT 因仓库相对路径被当成当前目录下的路径而在提交前拒绝。换入、备份与恢复 MUST NOT 跟随符号链接去改链接目标。工作区是悬空符号链接时，MUST NOT 因目标不存在而在换入前失败，也 MUST NOT 创建该目标。提交后若新建 commit 中该路径的模式或 blob 与要提交的条目不一致，入口 MUST 非 0 退出。该 commit MUST 保留，MUST NOT 自动 `reset`。工作区仍 MUST 恢复为调用前的内容与类型。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 同一路径有两段 diff 头
- **WHEN** 一次 `--hunks` 补丁对同一路径包含两段各自带 `diff --git` 头的 diff，且这些 hunk 都是该文件相对 HEAD 的 diff 的子集
- **THEN** 新建 commit 中该文件 MUST 只含这些选中的 hunk
- **AND** 返回后工作区 MUST 仍包含未选中的 hunk
- **AND** 未选中的 hunk MUST NOT 从工作区消失

#### Scenario: 同一路径两种写法
- **WHEN** 用户只要暂存区，该路径的 index 相对 HEAD 有改动，工作区还有未暂存改动
- **AND** 同一次调用用两种折成同一仓库相对路径的写法传入该路径，例如 `./f.txt` 与 `f.txt`
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 返回后工作区 MUST 仍包含调用前的未暂存改动
- **AND** 未暂存改动 MUST NOT 从工作区消失

#### Scenario: 子目录中按 hunk 提交
- **WHEN** 当前目录不是仓库根，路径参数相对该当前目录
- **AND** `--hunks` 补丁是该路径相对 HEAD 的 diff 的完整 hunk 子集
- **THEN** 该次调用 MUST 创建 commit
- **AND** 新建 commit 中该文件 MUST 只含选中的 hunk
- **AND** 未选中的 hunk MUST 仍留在工作区

#### Scenario: 暂存的符号链接在工作区已是普通文件
- **WHEN** 用户只要暂存区，index 中该路径为 `120000`，工作区中该路径已是普通文件
- **THEN** 新建 commit 中该路径 MUST 为 `120000`，链接目标 MUST 等于 index blob 的内容
- **AND** 返回后工作区中该路径 MUST 仍是调用前的普通文件

#### Scenario: 已暂存的可执行文件在工作区被删掉
- **WHEN** 用户只要暂存区，index 中该路径为 `100755`，工作区中该路径不存在
- **THEN** 新建 commit 中该路径 MUST 为 `100755`，内容 MUST 等于 index blob
- **AND** 返回后工作区中该路径 MUST 仍然不存在

#### Scenario: 工作区文件存在但模式与 index 不同
- **WHEN** 用户只要暂存区，index 中该路径为 `100755`，工作区中该路径是模式为 `100644` 的普通文件，且仍有未暂存内容
- **THEN** 新建 commit 中该路径 MUST 为 `100755`
- **AND** 返回后工作区文件的内容与模式 MUST 与调用前一致

#### Scenario: 符号链接两边目标不一致
- **WHEN** index 中该路径是指向目标 B 的符号链接，工作区中该路径仍是指向目标 A 的符号链接，且用户只要暂存区
- **THEN** 新建 commit 中该路径 MUST 为指向 B 的符号链接
- **AND** 目标 A 与目标 B 的内容 MUST 与调用前一致
- **AND** 返回后工作区中该路径 MUST 仍指向 A

#### Scenario: 悬空符号链接
- **WHEN** 工作区中该路径是指向不存在路径的符号链接，且 index 相对 HEAD 有可提交的改动
- **THEN** 该次调用 MUST 能创建 commit，commit 中该路径的模式与 blob MUST 等于 index
- **AND** MUST NOT 创建链接目标
- **AND** 返回后工作区 MUST 仍是调用前的悬空符号链接

### Requirement: Windows PowerShell 5.1 上枚举待换入列表 MUST 不中断提交
`scripts/commit_one.ps1` 在 Windows PowerShell 5.1 上 MUST 能枚举待换入路径与换入记录。该列表为空，或其中已有条目，都 MUST 能枚举完成。这次枚举 MUST NOT 在 `git commit` 之前因列表包装抛出类型错误而退出。消息与路径已通过现有检查时，该次调用 MUST 仍创建 commit。不合格消息 MUST 仍在创建 commit 之前拒绝，且 MUST NOT 创建该条 commit。`scripts/commit_one`、`scripts/validate` 与 `scripts/validate.ps1` 的规则 MUST 保持不变。

#### Scenario: 待换入列表为空时整文件提交仍创建 commit
- **WHEN** 在 Windows PowerShell 5.1 上用合格消息调用 `commit_one.ps1 --add`，路径是尚未进入 index 的整文件
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit 的文件集合 MUST 含该路径
- **AND** MUST NOT 在 `git commit` 之前因枚举待换入列表而退出

#### Scenario: 待换入列表已有条目时仍能枚举并提交
- **WHEN** 在 Windows PowerShell 5.1 上调用 `commit_one.ps1`，且该次调用在 `git commit` 之前已经记下至少一条待换入路径
- **THEN** 枚举这些条目 MUST 完成
- **AND** 消息与路径已通过现有检查时 MUST 创建 commit
- **AND** MUST NOT 因枚举该列表抛出类型错误

#### Scenario: 不合格消息仍在创建 commit 之前拒绝
- **WHEN** 在 Windows PowerShell 5.1 上把不合格 header 管道给 `commit_one.ps1`
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit

### Requirement: 未创建 commit 的失败 MUST 把 index 恢复到调用前
`commit_one` 在第一次改变 index 之前 MUST 记住调用时的 index。该次调用没有创建 commit 时，退出前 MUST 把 index 恢复成调用时的内容，MUST NOT 移动 HEAD。成功创建 commit 之后，index MUST 保持 `git commit` 留下的结果，MUST NOT 放回调用前。提交后的文件集合或 hunk 对照失败时，已创建的 commit MUST 保留，MUST NOT 自动 `reset`。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 夹带未改动文件时 index 回到调用前
- **WHEN** `--add` 的路径里除本次有差异的文件外，还包含一个相对 HEAD 与 index 都没有差异的文件
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** index MUST 与调用前一致

#### Scenario: git add 失败时已暂存的路径也被放回
- **WHEN** `--add` 的路径里包含一个有差异的文件和一个被忽略的文件，且 `git add` 非 0 退出
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** 那个有差异的文件在 index 中 MUST 与调用前一致

#### Scenario: 工作区回到 HEAD 时不盖掉 index 里的另一版
- **WHEN** 某路径的工作区内容与 HEAD 相同，index 中该路径的 blob 与 HEAD 不同，且对该路径使用 `--add`
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** index 中该路径的 blob MUST 仍是调用前的 blob

#### Scenario: hook 拒绝时 index 回到调用前
- **WHEN** `git commit` 因 hook 非 0 退出
- **THEN** MUST NOT 创建 commit
- **AND** index MUST 与调用前一致
- **AND** HEAD MUST 仍是调用前的 commit

#### Scenario: 成功提交后不放回调用前的 index
- **WHEN** `commit_one --add` 成功创建 commit
- **THEN** 该路径在 index 中的 blob MUST 等于新建 commit 中的 blob
- **AND** 未列入本次路径、调用前已暂存的其它路径 MUST 仍留在 index 中

#### Scenario: 提交后对照失败时保留 commit 与提交后的 index
- **WHEN** `git commit` 已经创建 commit，随后文件集合或 hunk 对照失败
- **THEN** 该次调用 MUST 非 0 退出
- **AND** 该 commit MUST 仍是 HEAD
- **AND** MUST NOT 自动 `reset`
- **AND** 已提交路径在 index 中的 blob MUST 等于该 commit，而不是调用前的 blob

### Requirement: 提交 MUST 锁预览路径
single 与 batch 在创建每条 commit 时，MUST 调用当前 shell 对应的入口，并把该条预览列出的仓库相对路径作为它的路径参数。当前 shell 是 sh、bash 或 zsh 时，入口 MUST 是技能目录中的 `scripts/commit_one`。当前 shell 是 Windows PowerShell 时，入口 MUST 是 `scripts/commit_one.ps1`。MUST NOT 在 PowerShell 中调用 `scripts/commit_one`，也 MUST NOT 在 sh 中调用 `scripts/commit_one.ps1`。下文的 `commit_one` 指这次实际调用的入口。该入口 MUST 把这些路径传给 `git commit --only`（或等价的「命令行给出路径」模式）。该 commit 的文件集合 MUST 等于这些路径，MUST NOT 把 index 中其它已暂存路径带进去。未列入该条的已暂存路径在提交后 MUST 仍留在 index。rename 或 delete 时，锁路径 MUST 包含该条预览列出的旧路径与新路径。默认输入为整棵工作树时，对 index 与 HEAD 相同或尚未进入 index 的整文件路径，`commit_one` MUST 先执行 `git add --`，以便纳入 untracked 与仅存在于工作区的改动。index 相对 HEAD 已有改动且工作区还有更多改动的路径，MUST NOT `git add` 工作区全文，MUST 提交 index 中的模式与 blob，未暂存改动 MUST 留在工作区。工作区中该路径已不存在、且 index 相对 HEAD 已有改动时，`--add` MUST NOT 对该路径执行 `git add`，MUST 提交 index 中的模式与 blob，返回后该路径 MUST 仍不存在于工作区；该次调用在创建 commit 之前失败时，工作区 MUST 仍不存在该路径，index MUST 回到调用前。index 与 HEAD 的模式和 blob 相同、工作区中该路径已不存在时，`--add` MUST 仍执行 `git add`，该 commit MUST 记录这次删除。尚未进入 HEAD、仅 index 中有该路径、工作区中该路径已不存在时，`--add` MUST 在创建 commit 之前非 0 退出，MUST NOT 创建 commit，index MUST 回到调用前。已暂存 rename 的旧路径已不在工作区、也不在 index 时，MUST NOT 对该旧路径执行 `git add --`；新旧路径都列入参数时，这条 commit MUST 是一次 rename。用户只要暂存区时，对整文件路径 MUST NOT `git add` 未暂存文件。被标为部分提交的已跟踪路径 MUST NOT 先 `git add` 工作区全文，MUST 提交由当前 HEAD 版本加上该条 hunk 得到的 blob；若 index 中该路径的 blob 已等于这个结果，MUST 改提交该 index blob。`commit_one` MUST NOT 因路径名像密钥、凭证或个人信息而拒绝参数中的路径。`--add` 时，一次调用里折成同一仓库相对路径的参数 MUST 只换入一次，恢复 MUST 用调用前的工作区。index 与 HEAD 相同、因此对该路径执行 `git add` 时，重复参数 MUST NOT 取消第一次 `git add`。HEAD 中有、index 与工作区都没有的已暂存删除，`--add` MUST NOT 对该路径执行 `git add`，该 commit MUST 记录这次删除。工作区已删除但 index 仍有该路径时，`--add` MUST 仍对该路径执行 `git add`。删除已暂存且该文件又出现在工作区时，不论是否带 `--add`，该 commit MUST 记录这次删除，后出现的内容 MUST NOT 进入历史，返回后 MUST 仍在工作区。该次调用在创建 commit 之前失败时，MUST 把这个文件放回调用前的内容。已暂存改名不再被识别为 rename、而是删除加新增，且新旧路径都列入参数时，`--add` MUST 创建 commit，MUST NOT 因旧路径匹配不到文件而以非 0 退出。git 仍把这次改动识别为 rename，且参数只有旧路径、新路径不在其中时，不论是否带 `--add`，MUST 在创建 commit 之前退出，MUST NOT 创建删除该旧路径的 commit，index MUST 保持这次改名。git 已把该次改动看成删除加新增时，只传入旧路径 MUST 仍提交这次删除。copy 的旧路径仍在工作区与 index 中时，MUST NOT 按 rename 的旧路径跳过；有未暂存改动时 MUST 只提交 index，否则 MUST 执行 `git add`。sh 与 PowerShell 入口 MUST 使用同一规则。

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

#### Scenario: 已暂存修改且工作区文件已删除时 --add 提交 index
- **WHEN** 某路径已在 HEAD 中，index 相对 HEAD 已有改动，工作区中该路径不存在，且 `commit_one --add` 的参数包含该路径
- **THEN** 新建 commit 中该路径的模式与 blob MUST 等于调用前 index 中的条目
- **AND** MUST NOT 把该 commit 记成删除该路径
- **AND** 返回后工作区 MUST 仍不存在该路径

#### Scenario: 只改了模式且工作区文件已删除时 --add 提交该模式
- **WHEN** 某路径已在 HEAD 中，index 的 blob 与 HEAD 相同但模式不同，工作区中该路径不存在，且 `commit_one --add` 的参数包含该路径
- **THEN** 新建 commit 中该路径的模式 MUST 等于调用前 index 中的模式
- **AND** 返回后工作区 MUST 仍不存在该路径

#### Scenario: 提交前失败时已删除的工作区文件仍缺失
- **WHEN** 某路径已在 HEAD 中，index 相对 HEAD 已有改动，工作区中该路径不存在，且 `commit_one --add` 在创建 commit 之前失败
- **THEN** MUST NOT 创建 commit
- **AND** 工作区 MUST 仍不存在该路径
- **AND** index 中该路径的模式与 blob MUST 与调用前一致

#### Scenario: index 与 HEAD 相同且工作区已删除时 --add 仍提交删除
- **WHEN** 某路径的 index 与 HEAD 的模式和 blob 相同，工作区中该路径已删除，且 `commit_one --add` 的参数包含该路径
- **THEN** 新建 commit MUST 记录这次删除

#### Scenario: 新文件只暂存且工作区已删除时 --add 在提交前退出
- **WHEN** 某路径尚未进入 HEAD，仅 index 中有该路径，工作区中该路径不存在，且 `commit_one --add` 的参数包含该路径
- **THEN** 该次调用 MUST 在创建 commit 之前非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** index 中该路径的模式与 blob MUST 与调用前一致

#### Scenario: --add 同一路径两种写法只换入一次
- **WHEN** `commit_one --add` 用两种折成同一仓库相对路径的写法传入同一路径，例如 `./note.txt` 与 `note.txt`
- **AND** 该路径的 index 相对 HEAD 已有改动，工作区还有更多改动
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 返回后工作区 MUST 仍包含调用前的未暂存改动

#### Scenario: 重复参数但 index 与 HEAD 相同时仍暂存工作区
- **WHEN** `commit_one --add` 用两种折成同一仓库相对路径的写法传入同一路径
- **AND** 该路径的 index 与 HEAD 相同，工作区有改动
- **THEN** 新建 commit 中该文件 MUST 等于工作区全文

#### Scenario: 已暂存的删除可以 --add
- **WHEN** 某路径已用删除进入 index，工作区中该路径不存在，且 `commit_one --add` 的参数包含该路径
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit MUST 记录这次删除
- **AND** MUST NOT 因路径匹配不到文件而以非 0 退出

#### Scenario: 尚未暂存的工作区删除仍由 --add 纳入
- **WHEN** 某路径仍在 index 中，工作区中该路径已删除，且 `commit_one --add` 的参数包含该路径
- **THEN** 新建 commit MUST 记录这次删除

#### Scenario: 删除已暂存且文件又出现在工作区
- **WHEN** 某路径的删除已在 index 中，工作区又出现该文件，且对该路径调用 `commit_one`，不论是否带 `--add`
- **THEN** 新建 commit MUST 记录这次删除
- **AND** 后出现的内容 MUST NOT 进入该 commit
- **AND** 返回后工作区 MUST 仍是调用前的该文件

#### Scenario: 挪走后出现的文件之后提交失败
- **WHEN** 删除已暂存且工作区又出现该文件，`commit_one` 在创建 commit 之前失败
- **THEN** MUST NOT 创建 commit
- **AND** 工作区中该文件 MUST 与调用前一致

#### Scenario: 改名不再被识别为 rename 时 --add 两个路径
- **WHEN** 已暂存的 `old.txt` 到 `new.txt` 不再被识别为 rename，而是删除加新增
- **AND** `commit_one --add` 的路径同时包含旧路径与新路径
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit MUST 包含旧路径的删除与新路径的新增
- **AND** MUST NOT 因旧路径匹配不到文件而以非 0 退出

#### Scenario: 只给 rename 的旧路径
- **WHEN** index 中已是 `old.txt -> new.txt`，且 `commit_one` 的参数只有旧路径，不论是否带 `--add`
- **THEN** 该次调用 MUST 在创建 commit 之前退出
- **AND** MUST NOT 创建删除旧路径的 commit
- **AND** index MUST 仍是这次改名

#### Scenario: 相似度不足时只给旧路径仍提交删除
- **WHEN** 已暂存的旧路径到新路径不再被识别为 rename，而是删除加新增
- **AND** `commit_one` 的参数只有旧路径
- **THEN** 新建 commit MUST 记录旧路径的这次删除
- **AND** 新路径 MUST 仍留在 index 中

#### Scenario: copy 的旧路径不按 rename 跳过
- **WHEN** index 中已是某路径复制到另一路径，旧路径仍在工作区与 index 中，且工作区相对 index 还有未暂存改动
- **AND** `commit_one --add` 的路径包含该旧路径
- **THEN** 新建 commit 中该旧路径的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 未暂存改动 MUST 仍留在工作区

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

### Requirement: 目录参数或相对 HEAD 无差异的路径 MUST 在创建 commit 之前失败
`commit_one` MUST 在调用 `git commit` 之前判断路径参数能否原样成为该次 commit 的文件集合。任一参数在调用时是目录，或规范化之后相对 `HEAD` 没有差异、因而不会出现在该次 commit 中时，该次调用 MUST 非 0 退出，MUST NOT 创建该条 commit。参数都是有差异的文件，且重命名或删除同时给出了旧路径与新路径时，这项预检 MUST NOT 拒绝该次调用。预检使用的路径身份与提交后的文件集合对照相同。

#### Scenario: 目录参数不创建 commit
- **WHEN** `commit_one` 的路径参数包含一个目录，且消息已通过提交前检查
- **THEN** 该次调用 MUST 在 `git commit` 之前非 0 退出
- **AND** MUST NOT 创建该条 commit

#### Scenario: 夹带未改动文件不创建 commit
- **WHEN** 路径参数里除本次有差异的文件外，还包含一个相对 `HEAD` 没有差异的文件
- **THEN** 该次调用 MUST 在 `git commit` 之前非 0 退出
- **AND** MUST NOT 创建该条 commit

#### Scenario: 有差异的文件通过预检
- **WHEN** 每个路径参数都是相对 `HEAD` 有差异的文件，且消息已通过提交前检查
- **THEN** 预检 MUST NOT 拒绝该次调用
- **AND** `commit_one` MUST 继续执行 `git commit`

#### Scenario: 重命名同时给出旧路径与新路径时预检通过
- **WHEN** 路径参数同时包含一次重命名的旧路径与新路径，且两者都会进入该次 commit
- **THEN** 预检 MUST NOT 因旧路径或新路径拒绝该次调用

### Requirement: 提交后 MUST 对照预览路径自检文件集合
`commit_one` 在 `git commit` 成功后，MUST 用 `git show --name-only`（rename 则用 `--name-status`）核对新建 commit 的路径是否等于本次调用的路径参数。比较前 MUST 把两侧路径收成仓库相对路径：去掉 `./`，并按调用时的当前目录补上仓库内前缀。收成同一路径后 MUST 视为一致。对不上时该次调用 MUST 非 0 退出，技能 MUST 视为自检失败：MUST 停止后续预定 commit，MUST 向用户报告实际路径与预览路径，MUST NOT 运行 `git push`，MUST NOT 输出成功回执，MUST NOT 自动 `reset` 已成功的 commit。

#### Scenario: 文件集合与预览一致
- **WHEN** 新建 commit 的路径与该次 `commit_one` 的路径参数在规范化之后一致
- **THEN** 技能 MUST 将本项自检视为通过
- **AND** 若其它自检也通过，可继续下一条或进入成功回执

#### Scenario: 带 ./ 前缀仍视为一致
- **WHEN** 路径参数为 `./` 加上仓库相对路径，且新建 commit 包含去掉该前缀后的同一路径
- **THEN** 文件集合对照 MUST 通过
- **AND** `commit_one` MUST 以 0 退出

#### Scenario: 非仓库根目录下的相对路径仍视为一致
- **WHEN** 调用 `commit_one` 时当前目录不是仓库根，路径参数相对该当前目录，且新建 commit 包含对应的仓库相对路径
- **THEN** 文件集合对照 MUST 通过
- **AND** `commit_one` MUST 以 0 退出

#### Scenario: 文件集合与预览不一致则停止
- **WHEN** 规范化之后，`git show` 列出的路径与该次 `commit_one` 的路径参数仍不一致
- **THEN** `commit_one` MUST 非 0 退出
- **AND** 技能 MUST 停止后续预定 commit
- **AND** MUST 报告实际路径与预览路径
- **AND** MUST NOT 运行 `git push`
- **AND** MUST NOT 使用成功回执开头
- **AND** 已成功的 commit MUST 保留

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
