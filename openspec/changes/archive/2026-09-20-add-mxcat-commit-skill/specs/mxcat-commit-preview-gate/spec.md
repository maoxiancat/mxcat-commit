## Purpose

定义 `mxcat-commit` 在任何实际 `git commit` 之前必须出示中文（或已覆盖语言）预览卡并等待用户确认；启动提交流程不等于批准稿件。

## ADDED Requirements

### Requirement: 技能 MUST 在用户确认前禁止创建 commit
在用户给出明确确认之前，技能 MUST NOT 运行 `git commit`（含 `--file`、`-m`、amend 创建新提交等会生成提交对象的命令）。用户仅表达「帮我提交」「自动提交」「split commits」或同类启动意图时，技能 MUST 只分析变更并出示预览，MUST NOT 提交。

#### Scenario: 启动语不是确认
- **WHEN** 用户说「帮我提交」或「把这些改动分批提交」且尚未对预览表态
- **THEN** 技能 MUST 输出预览卡
- **AND** MUST NOT 创建任何新的 git commit

#### Scenario: 明确确认后才提交
- **WHEN** 预览已出示且用户回复「确认」「可以提交」「lgtm」或「就这样」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致

### Requirement: 预览卡 MUST 包含标题、正文与解释
每次预览 MUST 对每条待提交变更出示：完整 header、完整 body（若有）、以及简短解释。解释 MUST 覆盖：为何选择该 emoji、为何选择该 scope、改动了哪些部分（模块、关键文件或行为）。解释 MUST NOT 逐行复述 diff。

#### Scenario: 单次提交预览
- **WHEN** 当前走 single 流程且已分析输入范围内的变更
- **THEN** 输出 MUST 包含拟用标题
- **AND** 输出 MUST 包含拟用正文（若需要 body）
- **AND** 输出 MUST 包含上述三类解释
- **AND** 此时工作区 HEAD MUST 尚未因本次请求前进

#### Scenario: 分批提交一次出齐预览
- **WHEN** 当前走 batch 流程且已分组
- **THEN** 输出 MUST 按顺序出示全部待确认条目（例如 1/N、2/N）
- **AND** 每条 MUST 具备标题、正文与解释
- **AND** 在用户确认整单之前 MUST NOT 创建其中任何一条 commit

### Requirement: 修改预览 MUST 重新出示且仍不提交
当用户要求修改标题、emoji、scope、正文或拆分/合并批次时，技能 MUST 更新预览卡并再次等待确认，MUST NOT 在同一次回复中提交。

#### Scenario: 用户改 scope
- **WHEN** 预览已出示且用户说把 scope 改成另一个值
- **THEN** 技能 MUST 输出更新后的预览
- **AND** MUST NOT 创建 commit

#### Scenario: 用户要求合并两条 batch
- **WHEN** 预览包含多条且用户要求将其中两条合并
- **THEN** 技能 MUST 输出合并后的整单预览
- **AND** MUST NOT 创建 commit

### Requirement: 仅在用户明确要求直接提交时可跳过预览
技能 MUST 仅在用户本轮已经给出完整标题，并且明确说「直接提交」或同等指令时，才允许不出示预览卡而提交。缺少完整标题或缺少「直接提交」意图时，MUST 走预览门禁。

#### Scenario: 完整标题且要求直接提交
- **WHEN** 用户提供完整 cz-emoji 标题并明确要求直接提交
- **THEN** 技能 MUST 允许跳过预览卡并提交
- **AND** 提交消息仍 MUST 遵守消息约定（默认中文、无 AI trailer、无 Jira 页脚）

#### Scenario: 只有标题但未说直接提交
- **WHEN** 用户提供了建议标题但只说「帮我提交」
- **THEN** 技能 MUST 仍出示预览卡
- **AND** MUST NOT 立即提交
