## ADDED Requirements

### Requirement: Scope token MUST NOT 含空白且 MUST 为单个括号
`(scope)` 括号内 MUST NOT 包含空格或制表符。标题 MUST 只含一个 `(scope)`，MUST NOT 写成 `(auth,api)` 或其它并列。提交后标题自检 MUST 将括号内含空白的标题判为失败。

#### Scenario: 括号内空白不合格
- **WHEN** 技能生成或定稿一条提交标题
- **THEN** `(scope)` 括号内 MUST NOT 含空白
- **AND** 标题 MUST NOT 形如 `:sparkles: (my scope) 增加空数据占位`

#### Scenario: 不得并列多个 scope
- **WHEN** 一条 commit 覆盖多于一个模块
- **THEN** 标题 MUST 只含一个 `(scope)`
- **AND** 标题 MUST NOT 形如 `:sparkles: (auth,api) 增加空数据占位`
- **AND** 技能 MUST 拆成多条 commit，或取该条的主面作为唯一 scope

#### Scenario: 无空白的合法 scope 可通过自检
- **WHEN** 标题为 `:sparkles: (charts) 增加空数据占位` 或 `:sparkles: (mxcat-commit) 增加空数据占位`
- **THEN** 标题自检 MUST 将该项视为通过（若其它自检也通过）

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
