## Purpose

定义 `mxcat-commit` 生成的最终提交消息必须满足的格式：cz-emoji shortcode 标题、默认简体中文描述，以及禁止 AI 署名与 Jira 页脚。

## ADDED Requirements

### Requirement: Header MUST 使用 cz-emoji shortcode 骨架
提交标题 MUST 匹配以下骨架之一：

- `:emoji: (scope) subject`
- `:emoji: (scope) ! subject`

Header 中的 emoji MUST 使用 shortcode（例如 `:bug:`），MUST NOT 使用 Unicode emoji。`scope` MUST 存在，且 MUST 写成 `(scope)`。`!` 若出现 MUST 位于 `(scope)` 之后、subject 之前。

#### Scenario: 普通提交必须带 scope
- **WHEN** 变更属于某个模块且不是破坏性变更
- **THEN** 标题 MUST 形如 `:sparkles: (charts) 增加空数据占位`
- **AND** 标题 MUST NOT 写成 `:sparkles: 增加空数据占位`
- **AND** 标题 MUST NOT 以 Unicode ✨ 开头
- **AND** 标题 MUST NOT 使用 `feat(charts):` 这类 Conventional Commits type 前缀

#### Scenario: 破坏性变更标记位置
- **WHEN** 提交包含破坏性变更
- **THEN** 标题 MUST 在 subject 前包含独立的 `!` 标记
- **AND** 标题 MUST 形如 `:emoji: (scope) ! subject`

### Requirement: Subject 与 Body 默认 MUST 使用简体中文
在用户本轮未明确要求其他语言时，header 的 subject 与 body 条目 MUST 使用简体中文。语言偏好只影响人类描述文本，MUST NOT 改变 `:emoji:`、`(scope)`、`!` 或 `BREAKING CHANGE:` 字段名。用户本轮明确要求英文（或其他语言）时，subject 与 body MUST 改用所要求语言。

#### Scenario: 默认中文
- **WHEN** 用户用中文或英文说「帮我提交」，且本轮未指定提交语言
- **THEN** 生成的 subject 与 body MUST 为简体中文

#### Scenario: 本轮要求英文覆盖默认
- **WHEN** 用户明确要求用英文写 commit message
- **THEN** subject 与 body MUST 使用英文
- **AND** `:emoji:` shortcode、必写的 `(scope)` 与可选的 `!` MUST 保持原语法

#### Scenario: BREAKING CHANGE 字段名保持英文
- **WHEN** 提交包含破坏性变更说明
- **THEN** footer 字段名 MUST 为 `BREAKING CHANGE:`
- **AND** 字段名后的描述文本 MUST 遵循当前语言偏好（默认简体中文）

### Requirement: 提交消息 MUST NOT 包含 AI 署名或 Jira 页脚
最终提交消息 MUST NOT 包含 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:` 或 `Jira-Refs:` 行。技能 MUST NOT 要求读取外部配置文件来决定消息格式。

#### Scenario: 无 AI trailer
- **WHEN** 技能生成或定稿一条提交消息
- **THEN** 消息全文 MUST NOT 匹配以 `AI-Co-Authored-By:` 开头的行
- **AND** MUST NOT 匹配以 `Co-authored-by:` 或 `Co-Authored-By:` 开头的行

#### Scenario: 无 Jira 页脚
- **WHEN** 用户消息或分支名中出现 Jira key 或 URL
- **THEN** 提交消息 MUST NOT 因此追加 `Jira-Refs:` 行

### Requirement: Body 格式 MUST 保持简洁列表
若存在 body，条目 MUST 使用 bullet 列表。Header 与 body 之间 MUST 有一个空行。若存在 footer（例如 `BREAKING CHANGE:`），body 与 footer 之间 MUST 有一个空行。

#### Scenario: 标准多行消息
- **WHEN** 提交包含标题与两条 body
- **THEN** 消息 MUST 为标题、空行、再两条 bullet
- **AND** 标题与第一条 bullet 之间 MUST 恰好一个空行
