## ADDED Requirements

### Requirement: 创建的 commit 文件集合 MUST 等于该条预览路径
用户确认预览（或按门禁跳过预览）后，技能为每条创建的 commit，其文件集合 MUST 等于该条预览「改动部分」列出的仓库相对路径（跳过预览时，等于该条实际要提交的那组路径）。创建的 commit 消息仍 MUST 与预览标题和正文一致（跳过预览时仍 MUST 遵守消息约定）。技能 MUST NOT 把未列入该条的已暂存路径写入该 commit。

#### Scenario: 预览后提交的文件集合与预览一致
- **WHEN** 预览已出示且用户回复「提交」「确认提交」或「帮我提交」
- **THEN** 技能 MUST 按已确认预览创建对应 commit
- **AND** 每条新建 commit 的文件集合 MUST 等于该条预览列出的路径
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致

#### Scenario: 预览后提交并 push 时文件集合仍须一致
- **WHEN** 预览已出示且用户回复「提交并 push」
- **THEN** 技能 MUST 将当前预览视为已确认并创建对应 commit
- **AND** 每条新建 commit 的文件集合 MUST 等于该条预览列出的路径
- **AND** 创建的 commit 消息 MUST 与预览中的标题和正文一致

#### Scenario: 跳过预览时仍不得带上未纳入的已暂存路径
- **WHEN** 用户强调不需要预览并允许直接提交
- **THEN** 每条新建 commit 的文件集合 MUST 等于该条实际要提交的路径
- **AND** MUST NOT 包含未纳入该条的已暂存路径
