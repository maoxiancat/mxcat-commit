# mxcat-commit-message-convention Specification

## Purpose

定义 `mxcat-commit` 生成的最终提交消息必须满足的格式：cz-emoji shortcode 标题、默认简体中文描述，以及禁止 AI 署名与 Jira 页脚。

## Requirements

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

### Requirement: Scope token MUST NOT 含空白且 MUST 为单个括号
`(scope)` 括号内 MUST NOT 包含空格或制表符。标题 MUST 只含一个 `(scope)`，MUST NOT 写成 `(auth,api)` 或其它并列。括号内 MUST 是单个小写 token：只含小写字母、数字与连字符，MUST NOT 含逗号、空白、大写字母或并列的第二段。提交前 `validate` MUST 将括号内含空白、或不是上述单个 token 的标题判为失败，且 `commit_one` MUST NOT 创建该条 commit。

#### Scenario: 括号内空白不合格
- **WHEN** 技能生成或定稿一条提交标题
- **THEN** `(scope)` 括号内 MUST NOT 含空白
- **AND** 标题 MUST NOT 形如 `:sparkles: (my scope) 增加空数据占位`

#### Scenario: 不得并列多个 scope
- **WHEN** 一条 commit 覆盖多于一个模块
- **THEN** 标题 MUST 只含一个 `(scope)`
- **AND** 标题 MUST NOT 形如 `:sparkles: (auth,api) 增加空数据占位`
- **AND** 技能 MUST 拆成多条 commit，或取该条的主面作为唯一 scope

#### Scenario: 并列 scope 不创建 commit
- **WHEN** 送入 `validate` 或 `commit_one` 的标题为 `:sparkles: (auth,api) 增加空数据占位`
- **THEN** 提交前检查 MUST 失败
- **AND** MUST NOT 创建该条 commit

#### Scenario: 无空白的合法 scope 可通过检查
- **WHEN** 标题为 `:sparkles: (charts) 增加空数据占位` 或 `:sparkles: (mxcat-commit) 增加空数据占位`，且消息其余部分满足提交前检查
- **THEN** `validate` MUST 将该项视为通过

### Requirement: Scope MUST 按该条 commit 的主语选一个小写英文短词
生成标题时，`scope` MUST 是一个小写英文短词。连字符 MUST 仅在源名字本身含连字符时保留（例如 skill 包名 `mxcat-commit`）。`scope` MUST 按该条 commit 的主语选择，MUST NOT 按文件路径拼接，MUST NOT 依赖允许词表：

- 产品面、页面或功能 → 该面的短词（例如 `home`、`vote`、`charts`）
- 共享层或基础设施 → 该层的短词（例如 `styles`、`i18n`、`api`）
- 规范或流程工具 → 该工具的短词（例如 `openspec`）
- 宿主仓库中一批 skill 快照 → `skills`
- 只改某一个 skill → 该 skill 的包名（例如 `mxcat-commit`）

看不出单一主面时，技能 MUST 拆成多条 commit，MUST NOT 使用 `misc`、`all`、`update` 或 `wip` 作为 scope。同一产品面的多条独立 commit 共用同一个 scope 是合法的。Subject 的语言 MUST NOT 改变 scope 的写法。

#### Scenario: 产品面用该面短词
- **WHEN** 该条 commit 的主语是某个产品面、页面或功能
- **THEN** `(scope)` MUST 为该面的一个小写英文短词
- **AND** MUST NOT 写成路径或句子

#### Scenario: 共享层用该层短词
- **WHEN** 该条 commit 的主语是共享样式、文案层、接口或工具函数，而不是某个页面
- **THEN** `(scope)` MUST 为该层的一个小写英文短词（例如 `styles`、`i18n`、`api`、`utils`）

#### Scenario: 一批 skill 快照用 skills
- **WHEN** 该条 commit 更新宿主仓库中一批 skill 包快照
- **THEN** `(scope)` MUST 为 `skills`

#### Scenario: 只改某一个 skill 用包名
- **WHEN** 该条 commit 只改某一个 skill 的行为或文档
- **THEN** `(scope)` MUST 为该 skill 的包名

#### Scenario: 无主面则拆批而不是编占位词
- **WHEN** 变更跨多个无关产品面或共享层，且无法指出单一主语
- **THEN** 技能 MUST 拆成多条 commit
- **AND** MUST NOT 使用 `(misc)`、`(all)`、`(update)` 或 `(wip)`

#### Scenario: 中文 subject 仍用英文 scope
- **WHEN** subject 使用默认简体中文
- **THEN** `(scope)` MUST 仍为小写英文短词
- **AND** MUST NOT 使用中文 scope

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
最终提交消息 MUST NOT 包含 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:` 或 `Jira-Refs:` 行。技能 MUST NOT 要求读取外部配置文件来决定消息格式。提交前 `validate` MUST 拒绝去掉行首空白后以上述任一字段开头的行，且 `commit_one` MUST NOT 因此创建该条 commit。行中间提到这些字段、且去掉行首空白后并不以该字段开头的行，MUST NOT 仅因此失败。

#### Scenario: 无 AI trailer
- **WHEN** 技能生成或定稿一条提交消息
- **THEN** 消息全文 MUST NOT 匹配以 `AI-Co-Authored-By:` 开头的行
- **AND** MUST NOT 匹配以 `Co-authored-by:` 或 `Co-Authored-By:` 开头的行

#### Scenario: 无 Jira 页脚
- **WHEN** 用户消息或分支名中出现 Jira key 或 URL
- **THEN** 提交消息 MUST NOT 因此追加 `Jira-Refs:` 行

#### Scenario: 行首空白的禁止页脚不创建 commit
- **WHEN** 送入 `commit_one` 的消息含有一行，该行去掉行首空白后以 `Co-authored-by:`、`AI-Co-Authored-By:` 或 `Jira-Refs:` 开头
- **THEN** 提交前检查 MUST 失败
- **AND** MUST NOT 创建该条 commit

### Requirement: Body 格式 MUST 保持简洁列表
若存在 body，条目 MUST 使用 bullet 列表。Header 与 body 之间 MUST 有一个空行。若存在 footer（例如 `BREAKING CHANGE:`），body 与 footer 之间 MUST 有一个空行。

#### Scenario: 标准多行消息
- **WHEN** 提交包含标题与两条 body
- **THEN** 消息 MUST 为标题、空行、再两条 bullet
- **AND** 标题与第一条 bullet 之间 MUST 恰好一个空行

### Requirement: 提交前 validate MUST 拒绝不合规消息
`scripts/validate` MUST 只根据标准输入上的消息判定，MUST NOT 创建 commit，MUST NOT 读取固定共享路径。Windows PowerShell 上等价入口是 `scripts/validate.ps1`，规则相同。`commit_one` MUST 在 `git commit` 之前调用当前环境的这项检查。检查 MUST 拒绝：header 对不上 `:emoji: (scope) subject` 或 `:emoji: (scope) ! subject`（shortcode、必写且为单个小写 token 的 scope、可选的 `!`）；第一行之后有非空行，且该非空行出现在标题后第一处空行之前；去掉行首空白后以 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:` 或 `Jira-Refs:` 开头的行。只有标题（第一行之后没有非空行）MUST 通过。多于一个分隔空行，或 body 与 `BREAKING CHANGE:` 之间缺空行，MUST NOT 仅因此失败。任一检查失败时 `validate` 与 `commit_one` MUST 非 0 退出，且 MUST NOT 创建该条 commit。

#### Scenario: 标题与正文粘在一起则不创建 commit
- **WHEN** 送入 `commit_one` 的消息为标题后紧跟 body 行、中间没有空行
- **THEN** 提交前检查 MUST 失败
- **AND** MUST NOT 创建该条 commit

#### Scenario: 标题与正文粘连且后面另有空行则不创建 commit
- **WHEN** 送入 `validate` 的消息为合法标题、紧跟一条 body、再一个空行、再一行 `BREAKING CHANGE:`
- **THEN** 提交前检查 MUST 失败
- **AND** MUST NOT 创建该条 commit

#### Scenario: 标题、空行、正文则通过检查
- **WHEN** 送入 `validate` 的消息为标题、一个空行、再 body，且 header 合法、没有禁止页脚
- **THEN** `validate` MUST 以 0 退出

#### Scenario: 只有标题则通过检查
- **WHEN** 送入 `validate` 的消息只有标题，标题之后没有非空行，且 header 合法
- **THEN** `validate` MUST 以 0 退出

#### Scenario: 两个空行再正文不因此失败
- **WHEN** 送入 `validate` 的消息为合法标题、两个空行、再 body，且没有禁止页脚
- **THEN** 提交前检查 MUST NOT 仅因此失败

#### Scenario: 正文与 BREAKING CHANGE 之间缺空行不因此失败
- **WHEN** 送入 `validate` 的消息为合法标题、一个空行、一条 body、紧跟一行 `BREAKING CHANGE:`，且没有禁止页脚
- **THEN** 提交前检查 MUST NOT 仅因此失败

#### Scenario: 不合规 header 不创建 commit
- **WHEN** 送入 `commit_one` 的标题缺少 `(scope)`、括号内含空白，或使用 Unicode emoji
- **THEN** 提交前检查 MUST 失败
- **AND** MUST NOT 创建该条 commit

#### Scenario: 禁止页脚不创建 commit
- **WHEN** 送入 `commit_one` 的消息含有以 `Co-authored-by:`、`Co-Authored-By:`、`AI-Co-Authored-By:` 或 `Jira-Refs:` 开头的行
- **THEN** 提交前检查 MUST 失败
- **AND** MUST NOT 创建该条 commit

### Requirement: 常用类型 MUST 覆盖界面、格式、安全与添加依赖
生成标题时，常用类型短表 MUST 至少包含下列 shortcode，且语义 MUST 与下表一致。`:wrench:` MUST 表示配置，MUST NOT 写成「杂项」或其它兜底语义。

| Shortcode | 语义 |
|---|---|
| `:sparkles:` | 新功能 |
| `:bug:` | 修复 |
| `:lipstick:` | 界面和样式 |
| `:art:` | 代码结构或格式 |
| `:lock:` | 安全修复 |
| `:heavy_plus_sign:` | 添加依赖 |
| `:memo:` | 文档 |
| `:recycle:` | 重构 |
| `:zap:` | 性能 |
| `:white_check_mark:` | 测试 |
| `:wrench:` | 配置 |
| `:truck:` | 移动或重命名 |
| `:fire:` | 删除 |

选词（生成时遵守；自检不验 emoji 语义）：

- 界面或样式文件用 `:lipstick:`
- 代码结构或格式用 `:art:`
- 安全修复用 `:lock:`；普通缺陷仍用 `:bug:`
- 添加依赖用 `:heavy_plus_sign:`
- 配置文件用 `:wrench:`

依赖的升级、降级、移除或锁版本，只改文案或字面量，以及 CI、国际化，header 的 shortcode MUST 从完整类型表选取，MUST NOT 硬套进短表。界面改动同时改到文案时，仍用 `:lipstick:`。

#### Scenario: 界面改动用 lipstick
- **WHEN** 该条 commit 的主语是界面或样式
- **THEN** header MUST 使用 `:lipstick:`
- **AND** MUST NOT 使用 `:sparkles:` 或 `:wrench:`

#### Scenario: 代码格式用 art
- **WHEN** 该条 commit 的主语是代码结构或格式，而不是界面
- **THEN** header MUST 使用 `:art:`
- **AND** MUST NOT 使用 `:lipstick:`

#### Scenario: 安全修复用 lock
- **WHEN** 该条 commit 的主语是安全修复
- **THEN** header MUST 使用 `:lock:`
- **AND** MUST NOT 使用 `:bug:` 或 `:wrench:`

#### Scenario: 添加依赖用 heavy_plus_sign
- **WHEN** 该条 commit 的主语是添加依赖
- **THEN** header MUST 使用 `:heavy_plus_sign:`
- **AND** MUST NOT 使用 `:wrench:` 或 `:sparkles:`

#### Scenario: 配置仍用 wrench
- **WHEN** 该条 commit 的主语是修改配置
- **THEN** header MUST 使用 `:wrench:`
- **AND** 短表对 `:wrench:` 的语义 MUST 为配置

#### Scenario: 只改文案改用完整表
- **WHEN** 该条 commit 只更新文案或字面量，没有界面或样式改动
- **THEN** header MUST 使用完整类型表中的 `:speech_balloon:`
- **AND** MUST NOT 使用 `:lipstick:` 或 `:sparkles:`

#### Scenario: 界面同时改文案仍用 lipstick
- **WHEN** 该条 commit 更新界面或样式，并同时改到文案
- **THEN** header MUST 使用 `:lipstick:`

#### Scenario: 依赖升级或移除改用完整表
- **WHEN** 该条 commit 升级、降级、移除或锁定依赖版本
- **THEN** header MUST 从完整类型表的依赖管理类型中选择
- **AND** MUST NOT 使用 `:heavy_plus_sign:`、`:wrench:` 或 `:sparkles:`

#### Scenario: CI 与国际化改用完整表
- **WHEN** 该条 commit 的主语是 CI 或国际化
- **THEN** header MUST 从完整类型表中选择对应 shortcode
- **AND** MUST NOT 使用 `:wrench:` 或 `:sparkles:`
