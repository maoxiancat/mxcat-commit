## MODIFIED Requirements

### Requirement: 技能 MUST 在用户确认前禁止创建 commit
在用户给出明确确认之前，技能 MUST NOT 运行 `git commit`（含 `--file`、`-m`、amend 创建新提交等会生成提交对象的命令）。判定确认 MUST 按会话阶段，而不是一份与阶段无关的词表。本轮尚未出示预览时，用户说「提交」「帮我提交」「自动提交」「commit」或同类启动意图，技能 MUST 只分析变更并出示预览，MUST NOT 提交。预览已出示后，用户说「提交」「确认提交」「帮我提交」或同等批准 commit 的说法时，技能 MUST 按已确认预览创建对应 commit。预览已出示后用户说「提交并 push」时，技能 MUST 将预览视为已确认（随后是否 push 由 workflow 约定）。「确认」「可以提交」「lgtm」「就这样」单独出现时 MUST NOT 视为确认。

#### Scenario: 启动语不是确认
- **WHEN** 用户说「帮我提交」或「提交」或「把这些改动分批提交」，且本轮尚未出示预览
- **THEN** 技能 MUST 输出预览卡
- **AND** MUST NOT 创建任何新的 git commit

#### Scenario: 预览后说提交才创建 commit
- **WHEN** 预览已出示且用户回复「提交」「确认提交」或「帮我提交」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致
- **AND** MUST NOT 因此次确认而运行 `git push`

#### Scenario: 预览后说提交并 push 视为批准预览
- **WHEN** 预览已出示且用户回复「提交并 push」
- **THEN** 技能 MUST 将当前预览视为已确认并创建对应 commit
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致

### Requirement: 预览卡 MUST 包含标题、正文与解释
每次预览 MUST 对每条待提交变更出示：完整 header、完整 body（若有）、以及简短解释。解释 MUST 覆盖：为何选择该 emoji、为何选择该 scope、改动了哪些部分（模块、关键文件或行为）。解释 MUST NOT 逐行复述 diff。全部预览条目之后 MUST 另起一段输出固定收尾提示语，文案 MUST 与技能文档中的规定原文一致，MUST NOT 临场改写或把收尾写进某条的解释里。

#### Scenario: 单次提交预览
- **WHEN** 当前走 single 流程且已分析输入范围内的变更
- **THEN** 输出 MUST 包含拟用标题
- **AND** 输出 MUST 包含拟用正文（若需要 body）
- **AND** 输出 MUST 包含上述三类解释
- **AND** 输出 MUST 在预览卡之后包含固定收尾提示语
- **AND** 此时工作区 HEAD MUST 尚未因本次请求前进

#### Scenario: 分批提交一次出齐预览
- **WHEN** 当前走 batch 流程且已分组
- **THEN** 输出 MUST 按顺序出示全部待确认条目（例如 1/N、2/N）
- **AND** 每条 MUST 具备标题、正文与解释
- **AND** 输出 MUST 在全部条目之后包含同一段固定收尾提示语
- **AND** 在用户确认整单之前 MUST NOT 创建其中任何一条 commit

### Requirement: 修改预览 MUST 重新出示且仍不提交
当用户要求修改标题、emoji、scope、正文、拆分/合并批次，或不要提交某一预览条目时，技能 MUST 更新预览卡并再次等待确认，MUST NOT 在同一次回复中提交。丢掉某条时，该条对应文件 MUST 留在工作区，技能 MUST NOT 对这些文件运行 `git restore`、`git checkout` 或 `git reset`。剩余条目 MUST 整单重出（含固定收尾）。若已无剩余条目，技能 MUST 停止并说明没有待提交项，MUST NOT 创建 commit。

#### Scenario: 用户改 scope
- **WHEN** 预览已出示且用户说把 scope 改成另一个值
- **THEN** 技能 MUST 输出更新后的预览
- **AND** MUST 再次输出固定收尾提示语
- **AND** MUST NOT 创建 commit

#### Scenario: 用户要求合并两条 batch
- **WHEN** 预览包含多条且用户要求将其中两条合并
- **THEN** 技能 MUST 输出合并后的整单预览
- **AND** MUST 再次输出固定收尾提示语
- **AND** MUST NOT 创建 commit

#### Scenario: 用户不要提交第 N 条
- **WHEN** 预览包含多条且用户要求不要提交其中第 N 条
- **THEN** 技能 MUST 从预览中移除该条
- **AND** 该条列出的文件 MUST 仍留在工作区
- **AND** MUST NOT 对这些文件运行 `git restore`、`git checkout` 或 `git reset`
- **AND** MUST 输出剩余条目的整单预览与固定收尾
- **AND** MUST NOT 创建 commit

#### Scenario: 丢掉唯一一条预览
- **WHEN** 预览仅剩一条且用户要求不要提交该条
- **THEN** 技能 MUST 停止
- **AND** MUST 说明没有待提交项
- **AND** 该条文件 MUST 仍留在工作区
- **AND** MUST NOT 创建 commit

## ADDED Requirements

### Requirement: 固定收尾提示语 MUST 使用规定原文
预览卡之后的收尾 MUST 使用以下原文（可前后各一空行，不得改字、换序或增删分句）：尚未提交 commit 和 push，请回复「提交」「提交并 push」等进行提交、push，也可以合并 commit 或不要提交某个 commit。single 与 batch MUST 使用同一句。该句仅说明用户可以回复的动作，MUST NOT 把「合为一条」解释为跳过预览。

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

## REMOVED Requirements

### Requirement: 仅在用户明确要求直接提交时可跳过预览
**Reason**: 跳过条件改为用户强调不需要预览；「完整标题 + 直接提交」不再足以绕过预览卡。
**Migration**: 需要跳过预览时改说「不需要预览」或同等强调；否则先看预览再回复「提交」或「提交并 push」。
