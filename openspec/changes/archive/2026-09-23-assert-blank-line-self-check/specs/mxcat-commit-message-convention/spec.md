## ADDED Requirements

### Requirement: 提交后空行自检 MUST 可判定分隔空行
每条 `git commit` 成功后，技能 MUST 对新建 commit 的消息做可判定的空行自检，MUST NOT 仅靠打印消息或 `cat -vet` 目视。若 `git log` 的 `%B`（整段消息）在第一行之后仍有非空行，则 `%b`（标题后第一个空行之后的正文）MUST 非空；否则该项自检 MUST 失败。若第一行之后没有非空行（只有标题），该项 MUST 通过。自检失败时 MUST 停止后续预定 commit，MUST 向用户报告，MUST NOT 运行 `git push`，MUST NOT 输出成功回执，MUST NOT 自动 `reset` 已成功的 commit。该项 MUST NOT 仅因标题与正文之间存在多于一个空行、或 body 与 `BREAKING CHANGE:` 之间缺空行而失败。

#### Scenario: 标题与正文粘在一起则失败
- **WHEN** 新建 commit 的消息为标题后紧跟 body 行、中间没有空行
- **THEN** 空行自检 MUST 将该项视为失败
- **AND** 技能 MUST 停止后续预定 commit
- **AND** MUST NOT 运行 `git push`
- **AND** MUST NOT 使用成功回执开头

#### Scenario: 标题、空行、正文则通过
- **WHEN** 新建 commit 的消息为标题、一个空行、再 body
- **THEN** 空行自检 MUST 将该项视为通过（若其它自检也通过）

#### Scenario: 只有标题则通过
- **WHEN** 新建 commit 的消息只有标题，标题之后没有非空行
- **THEN** 空行自检 MUST 将该项视为通过（若其它自检也通过）

#### Scenario: 两个空行再正文不因此失败
- **WHEN** 新建 commit 的消息为标题、两个空行、再 body
- **THEN** 空行自检 MUST NOT 仅因此将该项视为失败
