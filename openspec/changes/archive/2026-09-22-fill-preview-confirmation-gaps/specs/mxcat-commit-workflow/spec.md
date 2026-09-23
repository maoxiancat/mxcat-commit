## MODIFIED Requirements

### Requirement: Batch 流程 MUST 预览整单后一次确认再按序提交
分批提交 MUST 由 agent 根据变更语义分组。整单预览在预览阶段得到批准后，技能 MUST 按预览顺序创建被批准的 commit。批准范围可以是整单，也可以是 preview-gate 约定的点名子集。批准词遵循 preview-gate 的会话阶段规则。任一条创建失败时，MUST 停止后续提交并报告已成功与未成功的条目，MUST NOT 假装整单或该子集已完成，MUST NOT 运行 `git push`。

#### Scenario: 确认后按序提交
- **WHEN** 预览已出示且用户用独立的「提交」批准了包含多条的整单预览
- **THEN** 技能 MUST 按预览顺序依次创建 commit
- **AND** 每条消息 MUST 与对应预览条目一致
- **AND** MUST NOT 运行 `git push`

#### Scenario: 子集确认后按原序只提交被点名的条
- **WHEN** 预览已出示且用户点名只提交其中部分条目
- **THEN** 技能 MUST 按预览原序只创建被点名的那些 commit
- **AND** MUST NOT 创建未被点名的条目
- **AND** 未被点名条目列出的文件 MUST 仍留在工作区

#### Scenario: 中途失败停止
- **WHEN** 按序提交时某条 `git commit` 因 hook 或其他错误失败
- **THEN** 技能 MUST NOT 继续创建后续预览中的 commit
- **AND** MUST 向用户报告哪些条目已成功、哪一条失败、哪些尚未尝试
- **AND** MUST NOT 运行 `git push`

### Requirement: 丢掉的预览条目 MUST 把文件留在工作区
当用户不要提交某一预览条目时，技能 MUST 只从预览计划中移除该条，MUST NOT 用 git 命令丢弃或还原该条列出的工作区改动。若该句没有用独立的「提交」批准剩余条目，其余条目 MUST 作为新的整单预览再次等待批准。若该句同时批准剩余条目，技能 MUST 按 preview-gate 的子集规则当场提交剩余条，MUST NOT 再出一轮剩余预览等待。

#### Scenario: 丢掉一条后其余仍待确认
- **WHEN** 预览含多条且用户不要提交其中一条，且该句没有批准剩余条目
- **THEN** 被丢掉条目的文件 MUST 仍出现在工作区未提交变更中
- **AND** 技能 MUST 对剩余条目重新出示预览
- **AND** MUST NOT 在同一次回复中提交剩余条目

#### Scenario: 丢掉同时批准剩余则不重出再等
- **WHEN** 预览含多条且用户不要提交其中一条，同一句还用独立的「提交」批准剩余条目
- **THEN** 被丢掉条目的文件 MUST 仍出现在工作区未提交变更中
- **AND** 技能 MUST 按原序创建剩余条目
- **AND** MUST NOT 再对剩余条目出示预览等待
