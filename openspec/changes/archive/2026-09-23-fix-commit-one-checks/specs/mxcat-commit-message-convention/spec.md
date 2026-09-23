## MODIFIED Requirements

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
