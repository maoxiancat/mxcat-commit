## ADDED Requirements

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
