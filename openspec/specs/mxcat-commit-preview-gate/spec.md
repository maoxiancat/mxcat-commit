# mxcat-commit-preview-gate Specification

## Purpose

定义 `mxcat-commit` 在任何实际 `git commit` 之前必须出示中文（或已覆盖语言）预览卡并等待用户确认；启动提交流程不等于批准稿件。

## Requirements

### Requirement: 技能 MUST 在用户确认前禁止创建 commit
在用户给出明确确认之前，技能 MUST NOT 运行 `git commit`（含 `--file`、`-m`、amend 创建新提交等会生成提交对象的命令）。判定确认 MUST 按会话阶段，而不是一份与阶段无关的词表。本轮尚未出示预览时，用户说「提交」「帮我提交」「提交并 push」「提交并push」「commit and push」「自动提交」「commit」或同类启动意图，技能 MUST 只分析变更并出示预览与固定收尾，MUST NOT 提交，MUST NOT push。固定收尾中举例的「提交并 push」仅描述预览**之后**可用的确认语，MUST NOT 被解释为允许首轮跳过预览。预览已出示后，若用户这句话的主要动作是下令创建 commit（独立的「提交」），技能 MUST 按当前预览创建对应 commit；点名子集或同一句改稿时，范围与是否同轮提交由本能力其余要求约定。独立的「提交」不要求等于「提交」两个字，包括但不限于「提交」「确认提交」「帮我提交」「提交吧」「那就提交」「先提交」「好的，提交吧」「可以提交」，以及预览后的 `commit`。同一句里的软附和加上独立的「提交」仍是批准。预览已出示后用户说「提交并 push」时，技能 MUST 将预览视为已确认（随后是否 push 由 workflow 约定）。「确认」「可以」「好的」「行」「ok」「lgtm」「就这样」单独出现时 MUST NOT 视为确认。疑问句（例如「可以提交吗」「提交吗」）MUST NOT 视为确认。「不要提交」「先别提交」中的「提交」MUST NOT 视为独立的「提交」。

#### Scenario: 启动语不是确认
- **WHEN** 用户说「帮我提交」或「提交」或「把这些改动分批提交」，且本轮尚未出示预览
- **THEN** 技能 MUST 输出预览卡
- **AND** MUST NOT 创建任何新的 git commit

#### Scenario: 首轮提交并 push 仍须先预览
- **WHEN** 用户在本轮尚未出示预览时就说「提交并 push」或「提交并push」（含作为首条消息）
- **THEN** 技能 MUST 输出预览卡与固定收尾
- **AND** MUST NOT 创建任何新的 git commit
- **AND** MUST NOT 运行 `git push`

#### Scenario: 预览后说提交才创建 commit
- **WHEN** 预览已出示且用户回复「提交」「确认提交」或「帮我提交」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致
- **AND** MUST NOT 因此次确认而运行 `git push`

#### Scenario: 预览后说好的提交吧视为批准
- **WHEN** 预览已出示且用户回复「好的，提交吧」或「那就提交」或「提交吧」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** MUST NOT 因此次确认而运行 `git push`

#### Scenario: 预览后说可以提交视为批准
- **WHEN** 预览已出示且用户回复「可以提交」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** MUST NOT 因此次确认而运行 `git push`

#### Scenario: 预览后说提交并 push 视为批准预览
- **WHEN** 预览已出示且用户回复「提交并 push」
- **THEN** 技能 MUST 将当前预览视为已确认并创建对应 commit
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致

#### Scenario: 单独软附和不是确认
- **WHEN** 预览已出示且用户只回复「确认」或「可以」或「好的」或「lgtm」或「就这样」
- **THEN** 技能 MUST NOT 创建 commit
- **AND** MUST NOT 运行 `git push`

#### Scenario: 疑问句不是确认
- **WHEN** 预览已出示且用户回复「可以提交吗」或「提交吗」
- **THEN** 技能 MUST NOT 创建 commit

### Requirement: 预览卡 MUST 包含标题、正文与解释
每次预览 MUST 对每条待提交变更出示：以 `## commit N` 起头的二级标题、完整 header、完整 body（若有）、以及简短解释。`N` 为本计划内从 1 起分配的稳定编号。MUST NOT 使用 `待确认 · N/N`、`1/N` 或其他分数式标题。解释 MUST 覆盖：为何选择该 emoji、为何选择该 scope、改动了哪些部分（模块、关键文件或行为）。说明改动部分时，列出的每个文件 MUST 使用仓库相对路径并写在反引号内，以便跳转到对应文件；需要定位改动行时 MAY 使用 `` `startLine:endLine:path` `` 代码引用。解释 MUST NOT 只写裸文件名、MUST NOT 逐行复述 diff。全部预览条目之后 MUST 另起一段输出固定收尾提示语，文案 MUST 与技能文档中的规定原文一致，MUST NOT 临场改写或把收尾写进某条的解释里。

#### Scenario: 单次提交预览
- **WHEN** 当前走 single 流程且已分析输入范围内的变更
- **THEN** 输出 MUST 包含二级标题 `## commit 1`
- **AND** 输出 MUST 包含拟用标题
- **AND** 输出 MUST 包含拟用正文（若需要 body）
- **AND** 输出 MUST 包含上述三类解释
- **AND** 输出 MUST 在预览卡之后包含固定收尾提示语
- **AND** 此时工作区 HEAD MUST 尚未因本次请求前进

#### Scenario: 分批提交一次出齐预览
- **WHEN** 当前走 batch 流程且已分组
- **THEN** 输出 MUST 按顺序出示全部待确认条目，每条以 `## commit N` 为标题（首次出示时连续编号为 1、2、3…）
- **AND** 每条 MUST 具备标题、正文与解释
- **AND** 输出 MUST 在全部条目之后包含同一段固定收尾提示语
- **AND** 在用户确认整单之前 MUST NOT 创建其中任何一条 commit

### Requirement: 修改预览 MUST 重新出示且仍不提交
当用户要求修改标题、emoji、scope、正文、拆分/合并批次，或不要提交某一预览条目，且该句没有独立的「提交」时，技能 MUST 更新预览卡并再次等待确认，MUST NOT 在同一次回复中提交。丢掉某条且该句没有批准剩余条目时，该条对应文件 MUST 留在工作区，技能 MUST NOT 对这些文件运行 `git restore`、`git checkout` 或 `git reset`。剩余条目 MUST 整单重出（含固定收尾），且剩余条目标题编号 MUST 保持原号。若已无剩余条目，技能 MUST 停止并说明没有待提交项，MUST NOT 创建 commit。用户指某一条时，技能 MUST 按 `## commit N` 的编号匹配，MUST NOT 把「第 N 张」当成滑动后的列表下标。若同一句既改标题、emoji、scope 或正文，又含独立的「提交」，技能 MUST 按改完的稿创建 commit，MUST NOT 再出一轮预览等待。若改动是拆开、合并或改走「合为一条」，即使同一句含独立的「提交」，技能 MUST 仍输出更新后的预览并等待，MUST NOT 在同一次回复中提交。

#### Scenario: 用户改 scope
- **WHEN** 预览已出示且用户说把 scope 改成另一个值，且该句没有独立的「提交」
- **THEN** 技能 MUST 输出更新后的预览
- **AND** MUST 再次输出固定收尾提示语
- **AND** MUST NOT 创建 commit

#### Scenario: 改标题同时说提交则按新稿创建 commit
- **WHEN** 预览已出示且用户在同一句里把某条标题、emoji、scope 或正文改成新值，并含独立的「提交」
- **THEN** 技能 MUST 按改完的稿创建对应 commit
- **AND** MUST NOT 再出一轮预览等待
- **AND** 创建的 commit 消息 MUST 与改完后的标题和正文一致

#### Scenario: 用户要求合并两条 batch
- **WHEN** 预览包含多条且用户要求将其中两条合并，且该句没有独立的「提交」
- **THEN** 技能 MUST 输出合并后的整单预览
- **AND** 合并后的那条 MUST 使用被合并编号中较小的那个 `## commit N`
- **AND** 较大的那个编号 MUST 不再出现
- **AND** MUST 再次输出固定收尾提示语
- **AND** MUST NOT 创建 commit

#### Scenario: 拆开或合并即使带提交也先重出
- **WHEN** 预览包含多条且用户要求拆开或合并其中条目，同一句还含独立的「提交」
- **THEN** 技能 MUST 输出更新后的整单预览与固定收尾
- **AND** MUST NOT 在同一次回复中创建 commit

#### Scenario: 合为一条并提交仍先出 single 预览
- **WHEN** 当前为 batch 预览且用户说「合为一条」或「合为一条并提交」
- **THEN** 技能 MUST 改走 single 并出示单条预览与固定收尾
- **AND** MUST NOT 在同一次回复中创建 commit
- **AND** MUST NOT 将该要求视为跳过预览

#### Scenario: 用户不要提交第 N 条
- **WHEN** 预览包含多条且用户要求不要提交其中编号为 N 的条目（例如「不要提交 commit 2」），且该句没有批准剩余条目
- **THEN** 技能 MUST 从预览中移除该条
- **AND** 该条列出的文件 MUST 仍留在工作区
- **AND** MUST NOT 对这些文件运行 `git restore`、`git checkout` 或 `git reset`
- **AND** MUST 输出剩余条目的整单预览与固定收尾
- **AND** 剩余条目标题 MUST 保留原编号（例如原 1、2、3 丢掉 2 后仍为 `## commit 1` 与 `## commit 3`）
- **AND** MUST NOT 创建 commit

#### Scenario: 丢掉唯一一条预览
- **WHEN** 预览仅剩一条且用户要求不要提交该条
- **THEN** 技能 MUST 停止
- **AND** MUST 说明没有待提交项
- **AND** 该条文件 MUST 仍留在工作区
- **AND** MUST NOT 创建 commit

### Requirement: 预览条目编号 MUST 保持稳定身份
`## commit N` 的 `N` 是本轮预览计划里的身份，不是「当前还剩几条」的序号。条目首次进入预览时分配编号；本计划曾经用过的最大编号（含已丢掉或已合并消失的号）记为 max。拆开某条时，原编号 MUST 留给拆出的第一条，其余新条 MUST 依次使用 max+1、max+2…。技能 MUST NOT 在丢掉或合并后重编号以填补空号。

#### Scenario: 丢掉中间一条后编号不滑动
- **WHEN** 预览为 `## commit 1`、`## commit 2`、`## commit 3`，且用户不要提交 commit 2
- **THEN** 重出的预览 MUST 仍使用 `## commit 1` 与 `## commit 3`
- **AND** MUST NOT 把原来的 commit 3 改成 `## commit 2`

#### Scenario: 拆开一条时补新号
- **WHEN** 预览曾分配过编号 1、2、3（即使 2 已被丢掉），且用户要求把 commit 3 拆成两条
- **THEN** 拆出的第一条 MUST 仍为 `## commit 3`
- **AND** 拆出的第二条 MUST 为 `## commit 4`

### Requirement: 固定收尾提示语 MUST 使用规定原文
预览卡之后的收尾 MUST 使用以下原文（可前后各一空行，不得改字、换序或增删分句）：尚未提交。回复「提交」或「提交并 push」。single 与 batch MUST 使用同一句。该句仅提示两个确认口令，MUST NOT 被扩写成改稿或子集说明，MUST NOT 把「合为一条」解释为跳过预览。MUST NOT 改用其他等价句。

#### Scenario: 首次出示预览后跟固定收尾
- **WHEN** 技能输出单次或分批预览卡
- **THEN** 预览条目之后 MUST 出现上述原文
- **AND** 该原文 MUST NOT 被改写成其他确认说明

### Requirement: 仅当用户强调不需要预览时才可跳过预览
技能 MUST 仅在用户明确强调不需要预览（例如「不需要预览」「跳过预览」「不要预览」）时，才允许不出示预览卡而提交。用户仅说「直接提交」、仅提供完整标题、或启动语含「提交」时，MUST 仍走预览门禁。跳过预览时，提交消息仍 MUST 遵守消息约定。

#### Scenario: 用户强调不需要预览
- **WHEN** 用户明确强调不需要预览
- **THEN** 技能 MUST 允许跳过预览卡与固定收尾并提交
- **AND** 提交消息仍 MUST 遵守消息约定（默认中文、无 AI trailer、无 Jira 页脚）

#### Scenario: 直接提交或完整标题仍须预览
- **WHEN** 用户提供了建议或完整 cz-emoji 标题，并说「直接提交」或「帮我提交」，但未强调不需要预览
- **THEN** 技能 MUST 仍出示预览卡与固定收尾
- **AND** MUST NOT 立即提交

### Requirement: 创建的 commit 文件集合 MUST 等于该条预览路径
用户确认预览（或按门禁跳过预览）后，技能为每条创建的 commit，其文件集合 MUST 等于该条预览「改动部分」列出的仓库相对路径（跳过预览时，等于该条实际要提交的那组路径）。创建的 commit 消息仍 MUST 与预览标题和正文一致（跳过预览时仍 MUST 遵守消息约定）。技能 MUST NOT 把未列入该条的已暂存路径写入该 commit。

#### Scenario: 预览后提交的文件集合与预览一致
- **WHEN** 预览已出示且用户回复「提交」「确认提交」或「帮我提交」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** 每条新建 commit 的文件集合 MUST 等于该条预览列出的路径
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致

#### Scenario: 预览后提交并 push 时文件集合仍须一致
- **WHEN** 预览已出示且用户回复「提交并 push」
- **THEN** 技能 MUST 将当前预览视为已确认并创建对应 commit
- **AND** 每条新建 commit 的文件集合 MUST 等于该条预览列出的路径
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致

#### Scenario: 跳过预览时仍不得带上未纳入的已暂存路径
- **WHEN** 用户强调不需要预览并允许直接提交
- **THEN** 每条新建 commit 的文件集合 MUST 等于该条实际要提交的路径
- **AND** MUST NOT 包含未纳入该条的已暂存路径

### Requirement: 预览 MUST 提醒尚未进入 HEAD 的密钥与个人信息
当某条预览的「改动部分」含有明显是密钥、凭证或个人信息、且尚未出现在 HEAD 中的路径时，技能 MUST 在全部 `## commit N` 条目之后、固定收尾之前列出这些路径（仓库相对路径，写在反引号内），并说明确认提交会把它们写进历史。MUST NOT 从「改动部分」拿掉这些路径。MUST NOT 改写固定收尾原文。若没有此类路径，MUST NOT 凭空增加该提醒块。用户对已含该提醒的预览给出独立的「提交」或「提交并 push」时，技能 MUST 按已确认预览创建对应 commit，MUST NOT 再要求点名放行。

#### Scenario: 有未进仓库的 .env 时预览提醒且仍列入改动部分
- **WHEN** 输入范围内存在未跟踪的 `.env`，且还有业务文件
- **THEN** 某条预览的「改动部分」MUST 包含 `.env`
- **AND** MUST 在全部预览条目之后列出 `.env` 并提醒确认提交会写入历史
- **AND** MUST 随后输出固定收尾原文

#### Scenario: 无此类路径时不增加提醒块
- **WHEN** 输入范围内没有尚未进入 HEAD 的密钥、凭证或个人信息路径
- **THEN** 预览 MUST NOT 增加该提醒块

#### Scenario: 看过提醒后说提交即创建 commit
- **WHEN** 预览已出示且含上述提醒，用户回复「提交」「确认提交」或「帮我提交」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** 新建 commit 的文件集合 MUST 包含提醒中已列入「改动部分」的路径

### Requirement: 预览后点名子集 MUST 当场提交被点名的条
预览已出示后，用户点名只提交部分 `## commit N`（例如「只提交 commit 1」「提交 commit 1」「提交 1 和 3」「提交 1 和 3，2 先留着」），或丢掉某条的同时用独立的「提交」批准剩余条目（例如「不要提交 commit 2，其余提交」）时，技能 MUST 只创建被点名或被批准剩余的那些 commit，MUST 按预览原序创建它们，MUST NOT 创建未被点名的条目。未被点名的条目 MUST 视为丢掉：对应文件 MUST 留在工作区，技能 MUST NOT 对这些文件运行 `git restore`、`git checkout` 或 `git reset`。该次回复 MUST NOT 再对剩余条目出示预览并等待。用户指某一条时 MUST 按 `## commit N` 匹配；「第一条」「第二条」等滑动说法无法唯一对上编号时，技能 MUST 询问，MUST NOT 猜测，MUST NOT 创建 commit。仅说「2 先留着」或「不要提交 commit 2」、且没有批准剩余条目时，MUST 仍走「修改预览 MUST 重新出示且仍不提交」。单条预览下说「只提交 commit 1」MUST 视为批准该条。

#### Scenario: 只提交其中一条
- **WHEN** 预览为 `## commit 1`、`## commit 2`、`## commit 3`，且用户回复「只提交 commit 1」
- **THEN** 技能 MUST 创建 commit 1
- **AND** MUST NOT 创建 commit 2 或 commit 3
- **AND** commit 2 与 commit 3 列出的文件 MUST 仍留在工作区
- **AND** MUST NOT 再对 commit 2 与 commit 3 出示预览等待
- **AND** MUST NOT 对这些未提交文件运行 `git restore`、`git checkout` 或 `git reset`

#### Scenario: 提交某几条并留下其余
- **WHEN** 预览为 `## commit 1`、`## commit 2`、`## commit 3`，且用户回复「提交 1 和 3，2 先留着」
- **THEN** 技能 MUST 按原序创建 commit 1 再创建 commit 3
- **AND** MUST NOT 创建 commit 2
- **AND** commit 2 列出的文件 MUST 仍留在工作区
- **AND** MUST NOT 再出示剩余预览等待

#### Scenario: 丢掉同时批准剩余则当场提交剩余
- **WHEN** 预览含多条且用户回复「不要提交 commit 2，其余提交」
- **THEN** 技能 MUST 按原序创建除 commit 2 外的剩余条目
- **AND** MUST NOT 创建 commit 2
- **AND** MUST NOT 再出一轮剩余预览等待

#### Scenario: 只提交某条并 push
- **WHEN** 预览含多条，用户回复「只提交 commit 1 并 push」，且 commit 1 创建成功
- **THEN** 技能 MUST 只创建 commit 1
- **AND** MUST 在该条成功后运行恰好一次 `git push`（无上游等失败约束由 workflow 约定）
- **AND** MUST NOT 创建其余预览条目

#### Scenario: 滑动说法对不上则询问
- **WHEN** 预览已出示且用户说「只提交第二条」，无法唯一对上某个 `## commit N`
- **THEN** 技能 MUST 询问用户指哪一条
- **AND** MUST NOT 创建 commit

### Requirement: 同一路径分属多条预览时 MUST 标明各自 hunk
batch 预览中同一个仓库相对路径出现在多条里时，每条的「改动部分」MUST 标明该条带走的 hunk。这些 hunk MUST 来自预览当时该文件相对 HEAD 的 diff，各条之间 MUST NOT 重叠。解释 MUST NOT 逐行复述 diff；标明方式 MAY 使用行范围或 hunk 选择。用户确认后，每条新建 commit 中该文件的 diff MUST 等于该条标明的 hunk。确认前若选择对不上当时的 diff，技能 MUST 停止并说明，MUST NOT 创建该条 commit，MUST NOT 改成提交该文件的工作区全文。

#### Scenario: 两条预览各写自己的 hunk
- **WHEN** 同一已跟踪文件的两段改动被分进 `## commit 1` 与 `## commit 2`
- **THEN** 每条「改动部分」MUST 标明自己的 hunk
- **AND** 两条标明的 hunk MUST NOT 重叠
- **AND** 用户确认后每条 commit 中该文件的 diff MUST 等于该条标明的 hunk

#### Scenario: 标明的 hunk 对不上 diff
- **WHEN** 某条为共享路径标明的 hunk 不是当时相对 HEAD 的 diff 的子集，且用户已批准提交
- **THEN** 技能 MUST 在创建该条 commit 之前停止
- **AND** MUST NOT 提交该文件的工作区全文

#### Scenario: 解释仍不逐行复述
- **WHEN** 同一路径出现在两条预览中
- **THEN** 每条解释 MUST 标明该条的 hunk
- **AND** 解释 MUST NOT 逐行复述 diff
