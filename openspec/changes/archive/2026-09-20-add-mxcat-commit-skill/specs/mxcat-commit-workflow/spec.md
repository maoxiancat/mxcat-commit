## Purpose

定义 `mxcat-commit` 如何在默认加载层完成 single / batch 分流，如何按读取时机展开 reference，以及无脚本分批提交时必须遵守的流程边界。

## ADDED Requirements

### Requirement: 主技能文档 SHALL 先完成 single 与 batch 路由
触发本技能后，默认加载层 MUST 先判断走单次还是分批，而不是先展开全部执行细节。默认 MUST 走 batch：按逻辑拆分未提交变更，输入为整棵工作树（staged + unstaged + untracked）。仅当用户明确要求合为一条 commit 时，MUST 走 single。工作区只剩 staged、用户未要求合为一条时，MUST 仍走 batch。用户说「只提交暂存区」但未要求合为一条时，MUST 仍走 batch，且输入收缩为 staged。

#### Scenario: 用户只说帮我提交
- **WHEN** 用户要求提交且未声明「合为一个 commit」
- **THEN** 技能 MUST 进入 batch 流程
- **AND** 输入范围 MUST 为整棵未提交工作树
- **AND** MUST 在生成分批预览前读取 batch 流程的按需说明

#### Scenario: 仅有 staged 改动且未要求合成一条
- **WHEN** `git status --short` 显示只剩 staged 变更，且用户未要求合为一条 commit
- **THEN** 技能 MUST 进入 batch 流程
- **AND** MUST 按逻辑拆分这些 staged 变更（若只有一组，预览可以是 1/1）

#### Scenario: 存在未暂存或未跟踪改动
- **WHEN** 工作区存在 unstaged 或 untracked 改动，且用户未要求合为一条 commit
- **THEN** 技能 MUST 进入 batch 流程
- **AND** MUST 在生成分批预览前读取 batch 流程的按需说明

#### Scenario: 用户明确要求合为一条 commit
- **WHEN** 用户明确要求「合为一个 commit」或同等说法（如「合成一条」「不要拆」「就提交一条」）
- **THEN** 技能 MUST 走 single 流程
- **AND** 除非用户同时要求只提交暂存区，输入 MUST 为整棵未提交工作树

#### Scenario: 用户只要暂存区但仍要分批
- **WHEN** 用户明确要求只提交暂存区，且未要求合为一条 commit
- **THEN** 技能 MUST 走 batch 流程
- **AND** 输入 MUST 仅包含 staged 变更

### Requirement: 主技能文档 SHALL 将细节延迟到按需引用层
`SKILL.md` MUST 保留分流规则、预览门禁摘要和消息硬约束摘要，并把 single 执行细节、batch 分组细节、完整 emoji 类型表和故障排查放到 `references/`。主文档 MUST 明确写出何时读取哪份 reference。

#### Scenario: 首次读取主文档
- **WHEN** agent 因触发词加载 `SKILL.md`
- **THEN** 该文档 MUST 说明 single 与 batch 的分流条件
- **AND** MUST 摘要预览确认门禁
- **AND** MUST 摘要 header / 默认中文 / 禁止 AI trailer 与 Jira 页脚
- **AND** MUST 用表格或等价形式指出各 reference 的读取时机

#### Scenario: 需要完整 emoji 类型表
- **WHEN** 常用类型不足以覆盖当前语义
- **THEN** 技能 MUST 读取类型表 reference
- **AND** 默认加载层 MUST NOT 要求预先展开完整类型表

### Requirement: Batch 流程 MUST 预览整单后一次确认再按序提交
分批提交 MUST 由 agent 根据变更语义分组。整单预览得到确认后，技能 MUST 按预览顺序创建 commit。任一条创建失败时，MUST 停止后续提交并报告已成功与未成功的条目，MUST NOT 假装整单已完成。

#### Scenario: 确认后按序提交
- **WHEN** 用户确认了包含多条的整单预览
- **THEN** 技能 MUST 按预览顺序依次创建 commit
- **AND** 每条消息 MUST 与对应预览条目一致

#### Scenario: 中途失败停止
- **WHEN** 按序提交时某条 `git commit` 因 hook 或其他错误失败
- **THEN** 技能 MUST NOT 继续创建后续预览中的 commit
- **AND** MUST 向用户报告哪些条目已成功、哪一条失败、哪些尚未尝试

### Requirement: Batch 提交 MUST 使用常规 git 命令
本能力的分批提交 MUST 使用普通 git 命令完成暂存与提交。

#### Scenario: 用常规 git 命令提交
- **WHEN** agent 执行 batch 流程
- **THEN** 流程说明 MUST 使用 `git status`、`git diff`、`git add`、`git commit` 等常规命令
