## MODIFIED Requirements

### Requirement: 主技能文档 SHALL 将细节延迟到按需引用层
`SKILL.md` MUST 保留分流规则、预览门禁摘要和消息硬约束摘要，并把 single 执行细节、batch 分组细节、完整 emoji 类型表和故障排查放到 `references/`。主文档 MUST 明确写出何时读取哪份 reference。

#### Scenario: 首次读取主文档
- **WHEN** agent 因触发词加载 `SKILL.md`
- **THEN** 该文档 MUST 说明 single 与 batch 的分流条件
- **AND** MUST 摘要预览确认门禁
- **AND** MUST 摘要 header / 默认中文 / 禁止 AI trailer 与 Jira 页脚
- **AND** MUST 用表格或等价形式指出各 reference 的读取时机

#### Scenario: 需要完整 emoji 类型表
- **WHEN** 当前变更属于依赖的升级、降级、移除或锁版本，或只改文案与字面量，或属于 CI，或属于国际化
- **THEN** 技能 MUST 读取类型表 reference，并从该表选择 shortcode
- **AND** 默认加载层 MUST NOT 要求预先展开完整类型表

#### Scenario: 读取时机写明这些场合
- **WHEN** agent 读取主文档的 reference 表
- **THEN** 完整类型表的读取时机 MUST 点明依赖升级或移除、只改文案、CI 与国际化
- **AND** MUST NOT 把读取时机只写成「常用类型不足以覆盖当前语义」
