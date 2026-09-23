## MODIFIED Requirements

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
