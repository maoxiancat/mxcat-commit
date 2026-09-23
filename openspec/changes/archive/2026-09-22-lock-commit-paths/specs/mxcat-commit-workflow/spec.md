## ADDED Requirements

### Requirement: 提交 MUST 锁预览路径
single 与 batch 在创建每条 commit 时，MUST 把该条预览列出的仓库相对路径作为 `git commit` 的路径参数，并使用 `--only`（或等价的「命令行给出路径」模式，此时 git 默认即 only）。该 commit 的文件集合 MUST 等于这些路径，MUST NOT 把 index 中其它已暂存路径带进去。未列入该条的已暂存路径在提交后 MUST 仍留在 index。rename 或 delete 时，锁路径 MUST 包含该条预览列出的旧路径与新路径。默认输入为整棵工作树时，技能 MUST 先对这些路径执行 `git add --`，以便纳入 untracked；用户只要暂存区时 MUST NOT `git add` 未暂存文件。

#### Scenario: 其它已暂存路径不进入本次 commit
- **WHEN** index 中除预览路径外还暂存了其它文件，且用户已批准按该预览提交
- **THEN** 新建 commit 的文件集合 MUST 仅含该条预览列出的路径
- **AND** 那些未列入预览的已暂存路径 MUST 在提交后仍出现在 index 中

#### Scenario: 丢掉的预览条目即使仍暂存也不被吞入
- **WHEN** 用户不要提交某一预览条目，该条文件仍留在工作区且仍为 staged，随后用户批准提交剩余条目
- **THEN** 剩余条目对应的 commit MUST NOT 包含被丢掉条目列出的路径

#### Scenario: batch 下一条仍只锁本条路径
- **WHEN** batch 预览含两条不同路径，第一条已用 `--only` 提交成功，第二条路径仍为 staged
- **THEN** 第二条 commit 的文件集合 MUST 仅含第二条预览列出的路径

### Requirement: 提交后 MUST 对照预览路径自检文件集合
每条 `git commit` 成功后，技能 MUST 用 `git show --name-only`（rename 则用 `--name-status`）核对新建 commit 的路径是否等于该条预览列出的仓库相对路径。对不上时 MUST 视为自检失败：MUST 停止后续预定 commit，MUST 向用户报告实际路径与预览路径，MUST NOT 运行 `git push`，MUST NOT 输出成功回执，MUST NOT 自动 `reset` 已成功的 commit。

#### Scenario: 文件集合与预览一致
- **WHEN** 新建 commit 的路径与该条预览列出的路径一致
- **THEN** 技能 MUST 将本项自检视为通过
- **AND** 若其它自检也通过，可继续下一条或进入成功回执

#### Scenario: 文件集合与预览不一致则停止
- **WHEN** `git show` 列出的路径与该条预览列出的路径不一致
- **THEN** 技能 MUST 停止后续预定 commit
- **AND** MUST 报告实际路径与预览路径
- **AND** MUST NOT 运行 `git push`
- **AND** MUST NOT 使用成功回执开头
- **AND** 已成功的 commit MUST 保留

### Requirement: 只要暂存区且预览路径仍有未暂存改动时 MUST 停止
用户要求只提交暂存区时，技能 MUST 在提交前检查该条预览路径是否还有 unstaged 改动（例如这些路径上的 `git diff` 非空）。若仍有，MUST 停止并说明无法在文件粒度下只提交该文件的 staged hunk，MUST NOT 对这些路径 `git add`，MUST NOT 运行会把工作区多余 hunk 纳入该 commit 的 `git commit --only`。

#### Scenario: 只要暂存区且预览路径工作区干净
- **WHEN** 用户只要暂存区，且该条预览路径没有 unstaged 改动
- **THEN** 技能 MUST 允许用 `--only` 锁这些路径提交
- **AND** MUST NOT 对这些路径再 `git add`

#### Scenario: 只要暂存区但预览路径有未暂存改动
- **WHEN** 用户只要暂存区，且该条预览路径上仍有 unstaged 改动
- **THEN** 技能 MUST 停止
- **AND** MUST 说明无法只提交这些路径的 staged 部分
- **AND** MUST NOT 创建该条 commit
