## ADDED Requirements

### Requirement: 尚未进入 HEAD 的密钥与个人信息 MUST 仍编进预览
single 与 batch 在分组时，若某路径明显是密钥、凭证或个人信息，且该路径尚未出现在 HEAD 中（未跟踪或已暂存但从未提交），技能 MUST 仍把它写入某条预览的「改动部分」。技能 MUST NOT 使用硬编码文件名名单来决定排除或纳入。技能 MUST NOT 仅因这类路径而停止预览或拒绝创建条目。已在 HEAD 中的同名路径之修改 MUST NOT 仅因此被特殊处理。

#### Scenario: 未跟踪的 .env 仍编进预览
- **WHEN** 输入范围内存在未跟踪的 `.env`，且还有业务文件
- **THEN** 某条预览的「改动部分」MUST 包含该 `.env` 路径

#### Scenario: staged 新增的密钥仍编进预览
- **WHEN** 输入范围内存在已暂存、但 HEAD 中尚不存在的 `id_rsa` 或通讯录 csv 等明显密钥或个人信息路径
- **THEN** 某条预览的「改动部分」MUST 包含这些路径

#### Scenario: 已跟踪文件的修改不因该规则改变分组
- **WHEN** 某明显密钥路径已存在于 HEAD，本次输入只是该路径的修改
- **THEN** 技能 MUST NOT 仅因本规则把它从预览中拿掉或停止预览

### Requirement: `.agents/skills/*` 默认 MUST 与业务代码拆成不同预览条目
当输入范围内同时存在 `.agents/skills/` 下的路径与之外的业务路径时，技能 MUST 把 `.agents/skills/*` 编进与业务代码不同的预览条目。用户明确要求将它们与业务代码合并时，技能 MUST 允许合并。用户明确要求合为一条 commit 时，该要求视为允许将 skills 与业务写入同一条。

#### Scenario: skills 与业务同时存在时默认分开
- **WHEN** 输入范围内既有 `src/` 下的业务改动，也有 `.agents/skills/` 下的改动，且用户未要求合为一条或合并这些文件
- **THEN** 预览 MUST 至少包含一条只含 `.agents/skills/*` 路径的条目
- **AND** 业务路径 MUST NOT 出现在该条的「改动部分」

#### Scenario: 用户要求合为一条时允许混入 skills
- **WHEN** 用户明确要求合为一个 commit，且输入范围内同时有业务路径与 `.agents/skills/*`
- **THEN** 技能 MUST 允许把它们写入同一条预览

### Requirement: git 视为 binary 的路径默认 MUST 不与功能文件写在同一条
当 git 将某路径视为 binary（例如 `git diff --numstat` 对该路径显示 `-	-`），且输入范围内还有非 binary 的功能文件时，技能 MUST 把该 binary 路径编进与功能文件不同的预览条目，并在该条解释中点名这是二进制。用户明确要求合并或合为一条 commit 时，技能 MUST 允许将 binary 与功能文件写入同一条。

#### Scenario: 二进制与功能文件默认拆开
- **WHEN** 输入范围内同时存在非 binary 的功能文件与 git 视为 binary 的未跟踪或已修改文件，且用户未要求合并或合为一条
- **THEN** 预览 MUST 把 binary 路径放在与功能文件不同的条目中
- **AND** 该条解释 MUST 点名这是二进制

#### Scenario: 用户要求合为一条时允许混入二进制
- **WHEN** 用户明确要求合为一个 commit，且输入范围内同时有功能文件与 binary 路径
- **THEN** 技能 MUST 允许把它们写入同一条预览
