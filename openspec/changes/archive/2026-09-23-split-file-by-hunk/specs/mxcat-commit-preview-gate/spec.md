## ADDED Requirements

### Requirement: 同一路径分属多条预览时 MUST 标明各自 hunk
batch 预览中同一个仓库相对路径出现在多条里时，每条的「改动部分」MUST 标明该条带走的 hunk。这些 hunk MUST 来自预览当时该文件相对 HEAD 的 diff，各条之间 MUST NOT 重叠。解释 MUST NOT 逐行复述 diff；标明方式 MAY 使用行范围或 hunk 选择。用户确认后，每条新建 commit 中该文件的 diff MUST 等于该条标明的 hunk。确认前若选择对不上当时的 diff，技能 MUST 停止并说明，MUST NOT 创建该条 commit，MUST NOT 改成提交该文件的工作区全文。

#### Scenario: 两条预览各写自己的 hunk
- **WHEN** 同一已跟踪文件的两段改动被分进 `## commit 1` 与 `## commit 2`
- **THEN** 每条「改动部分」MUST 标明自己的 hunk
- **AND** 两条标明的 hunk MUST NOT 重叠
- **AND** 用户确认后每条 commit 中该文件的 diff MUST 等于该条标明的 hunk

#### Scenario: 标明的 hunk 对不上 diff
- **WHEN** 某条为共享路径标明的 hunk 不是当时相对 HEAD 的 diff 的子集，且用户已批准提交
- **THEN** 技能 MUST 在创建该条 commit 之前停止
- **AND** MUST NOT 提交该文件的工作区全文

#### Scenario: 解释仍不逐行复述
- **WHEN** 同一路径出现在两条预览中
- **THEN** 每条解释 MUST 标明该条的 hunk
- **AND** 解释 MUST NOT 逐行复述 diff
