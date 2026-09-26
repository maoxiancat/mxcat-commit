## ADDED Requirements

### Requirement: Windows PowerShell 5.1 上枚举待换入列表 MUST 不中断提交
`scripts/commit_one.ps1` 在 Windows PowerShell 5.1 上 MUST 能枚举待换入路径与换入记录。该列表为空，或其中已有条目，都 MUST 能枚举完成。这次枚举 MUST NOT 在 `git commit` 之前因列表包装抛出类型错误而退出。消息与路径已通过现有检查时，该次调用 MUST 仍创建 commit。不合格消息 MUST 仍在创建 commit 之前拒绝，且 MUST NOT 创建该条 commit。`scripts/commit_one`、`scripts/validate` 与 `scripts/validate.ps1` 的规则 MUST 保持不变。

#### Scenario: 待换入列表为空时整文件提交仍创建 commit
- **WHEN** 在 Windows PowerShell 5.1 上用合格消息调用 `commit_one.ps1 --add`，路径是尚未进入 index 的整文件
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit 的文件集合 MUST 含该路径
- **AND** MUST NOT 在 `git commit` 之前因枚举待换入列表而退出

#### Scenario: 待换入列表已有条目时仍能枚举并提交
- **WHEN** 在 Windows PowerShell 5.1 上调用 `commit_one.ps1`，且该次调用在 `git commit` 之前已经记下至少一条待换入路径
- **THEN** 枚举这些条目 MUST 完成
- **AND** 消息与路径已通过现有检查时 MUST 创建 commit
- **AND** MUST NOT 因枚举该列表抛出类型错误

#### Scenario: 不合格消息仍在创建 commit 之前拒绝
- **WHEN** 在 Windows PowerShell 5.1 上把不合格 header 管道给 `commit_one.ps1`
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit
