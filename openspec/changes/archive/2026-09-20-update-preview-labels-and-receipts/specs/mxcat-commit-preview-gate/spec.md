## MODIFIED Requirements

### Requirement: 预览卡 MUST 包含标题、正文与解释
每次预览 MUST 对每条待提交变更出示：以 `## commit N` 起头的二级标题、完整 header、完整 body（若有）、以及简短解释。`N` 为本计划内从 1 起分配的稳定编号。MUST NOT 使用 `待确认 · N/N`、`1/N` 或其他分数式标题。解释 MUST 覆盖：为何选择该 emoji、为何选择该 scope、改动了哪些部分（模块、关键文件或行为）。解释 MUST NOT 逐行复述 diff。全部预览条目之后 MUST 另起一段输出固定收尾提示语，文案 MUST 与技能文档中的规定原文一致，MUST NOT 临场改写或把收尾写进某条的解释里。

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
当用户要求修改标题、emoji、scope、正文、拆分/合并批次，或不要提交某一预览条目时，技能 MUST 更新预览卡并再次等待确认，MUST NOT 在同一次回复中提交。丢掉某条时，该条对应文件 MUST 留在工作区，技能 MUST NOT 对这些文件运行 `git restore`、`git checkout` 或 `git reset`。剩余条目 MUST 整单重出（含固定收尾），且剩余条目标题编号 MUST 保持原号。若已无剩余条目，技能 MUST 停止并说明没有待提交项，MUST NOT 创建 commit。用户指某一条时，技能 MUST 按 `## commit N` 的编号匹配，MUST NOT 把「第 N 张」当成滑动后的列表下标。

#### Scenario: 用户改 scope
- **WHEN** 预览已出示且用户说把 scope 改成另一个值
- **THEN** 技能 MUST 输出更新后的预览
- **AND** MUST 再次输出固定收尾提示语
- **AND** MUST NOT 创建 commit

#### Scenario: 用户要求合并两条 batch
- **WHEN** 预览包含多条且用户要求将其中两条合并
- **THEN** 技能 MUST 输出合并后的整单预览
- **AND** 合并后的那条 MUST 使用被合并编号中较小的那个 `## commit N`
- **AND** 较大的那个编号 MUST 不再出现
- **AND** MUST 再次输出固定收尾提示语
- **AND** MUST NOT 创建 commit

#### Scenario: 用户不要提交第 N 条
- **WHEN** 预览包含多条且用户要求不要提交其中编号为 N 的条目（例如「不要提交 commit 2」）
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

## ADDED Requirements

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
