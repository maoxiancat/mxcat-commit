## ADDED Requirements

### Requirement: 技能目录 SHALL 带上提交入口脚本
技能包 MUST 在 `skills/mxcat-commit/scripts/` 提供 `validate`、`commit_one`、`validate.ps1` 与 `commit_one.ps1`。`validate` 与 `commit_one` MUST 可执行。经 `npx skills` 安装得到的 `mxcat-commit` 技能目录 MUST 仍包含这四个路径。

#### Scenario: 源目录包含两个环境的入口
- **WHEN** 查看仓库中的 `skills/mxcat-commit/scripts/`
- **THEN** MUST 存在 `validate`、`commit_one`、`validate.ps1` 与 `commit_one.ps1`
- **AND** `validate` 与 `commit_one` MUST 可执行

#### Scenario: 安装结果仍包含入口
- **WHEN** 用 `npx skills` 安装 `mxcat-commit` 后查看该技能目录
- **THEN** 该目录下 MUST 仍有 `scripts/validate`、`scripts/commit_one`、`scripts/validate.ps1` 与 `scripts/commit_one.ps1`
