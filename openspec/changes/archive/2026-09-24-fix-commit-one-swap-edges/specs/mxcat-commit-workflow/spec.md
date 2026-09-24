## MODIFIED Requirements

### Requirement: 只要暂存区且路径仍有未暂存改动时 MUST 只提交 index blob
用户要求只提交暂存区，且该条路径上仍有未暂存改动时，`commit_one` MUST 提交该路径在 index 中的模式与 blob，MUST NOT `git add` 工作区全文，MUST NOT 把未暂存 hunk 写入该 commit。新建 commit 中该路径的类型与模式 MUST 等于 index 中的条目。调用返回后该路径的工作区内容与路径类型 MUST 与调用前一致，剩余改动 MUST 仍留在工作区。若该路径在 index 中的模式与 blob 都与 HEAD 相同，MUST 在创建 commit 之前退出，并说明没有可提交的已暂存改动。只改了模式、blob 与 HEAD 相同时，MUST 提交这个模式，MUST NOT 以没有已暂存改动为由退出。同一次调用还带 `--hunks` 时，未出现在该补丁中的路径 MUST 仍遵守本要求，MUST NOT 把这些路径的未暂存内容写入该 commit；补丁中的路径 MUST 仍只提交选中 hunk 对应的条目。当前目录不是仓库根时，本要求 MUST 与在仓库根调用时相同。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 已暂存的一半被提交
- **WHEN** 用户只要暂存区，该路径的 index 相对 HEAD 有改动，工作区还有更多改动
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 工作区字节 MUST 保持为调用前的内容
- **AND** 未暂存改动 MUST 仍出现在 `git diff` 中

#### Scenario: index 与 HEAD 相同
- **WHEN** 用户只要暂存区，该路径的未暂存 diff 非空，且 index 的模式与 blob 都与 HEAD 相同
- **THEN** `commit_one` MUST 在创建 commit 之前退出
- **AND** MUST NOT 提交这些未暂存 hunk

#### Scenario: 只暂存了可执行位
- **WHEN** 用户只要暂存区，index 中该路径为 `100755`，blob 与 HEAD 相同，工作区另有内容改动
- **THEN** 新建 commit 中该路径 MUST 为 `100755`，blob MUST 与 HEAD 相同
- **AND** 工作区内容 MUST 与调用前一致
- **AND** MUST NOT 把未暂存的内容改动写入该 commit

#### Scenario: hunks 旁路的已暂存文件
- **WHEN** 同一次调用用 `--hunks` 只提交路径 A 的一段 hunk，路径 C 不在该补丁中，且不带 `--add`
- **AND** C 的 index 相对 HEAD 有改动，工作区在这之上还有未暂存改动
- **THEN** 新建 commit 中 A MUST 只含选中的 hunk
- **AND** 新建 commit 中 C 的 diff MUST 等于 C 的 index 相对 HEAD 的 diff
- **AND** C 的未暂存改动 MUST 仍留在工作区
- **AND** A 的未选中 hunk MUST 仍留在工作区

#### Scenario: hunks 旁路但 index 与 HEAD 相同
- **WHEN** 同一次调用用 `--hunks` 提交其它路径的一段合法 hunk，且不带 `--add`
- **AND** 另一参数路径的未暂存 diff 非空，其 index 的模式与 blob 都与 HEAD 相同
- **THEN** `commit_one` MUST 在创建 commit 之前退出
- **AND** MUST NOT 把该路径的未暂存内容写入 commit

#### Scenario: 子目录中只提交已暂存内容
- **WHEN** 当前目录不是仓库根，路径参数相对该当前目录
- **AND** 用户只要暂存区，该路径的 index 相对 HEAD 有改动，工作区还有更多改动
- **THEN** 该次调用 MUST 创建 commit
- **AND** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 工作区字节 MUST 保持为调用前的内容

### Requirement: 换入提交 MUST 保持路径类型且不丢未选改动
按 hunk 提交，或不带 `--add` 提交 index 内容时，`commit_one` MUST 把要提交的模式与 blob 写入该次 commit。`100644` 与 `100755` MUST 保持对应模式。`120000` MUST 作为符号链接提交，链接目标 MUST 等于该 blob 的内容。调用返回后，该路径的工作区字节与路径类型 MUST 与调用前一致。同一路径在一次补丁里出现多个 `diff --git` 头时，MUST 只按该路径换入一次，未纳入的 hunk MUST 仍留在工作区。一次调用的路径参数折成同一仓库相对路径时，不论写法是否相同，MUST 只按该路径换入一次，恢复 MUST 用调用前的那一份。当前目录不是仓库根时，按 hunk 换入 MUST 与在仓库根调用时相同，MUST NOT 因仓库相对路径被当成当前目录下的路径而在提交前拒绝。换入、备份与恢复 MUST NOT 跟随符号链接去改链接目标。工作区是悬空符号链接时，MUST NOT 因目标不存在而在换入前失败，也 MUST NOT 创建该目标。提交后若新建 commit 中该路径的模式或 blob 与要提交的条目不一致，入口 MUST 非 0 退出。该 commit MUST 保留，MUST NOT 自动 `reset`。工作区仍 MUST 恢复为调用前的内容与类型。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 同一路径有两段 diff 头
- **WHEN** 一次 `--hunks` 补丁对同一路径包含两段各自带 `diff --git` 头的 diff，且这些 hunk 都是该文件相对 HEAD 的 diff 的子集
- **THEN** 新建 commit 中该文件 MUST 只含这些选中的 hunk
- **AND** 返回后工作区 MUST 仍包含未选中的 hunk
- **AND** 未选中的 hunk MUST NOT 从工作区消失

#### Scenario: 同一路径两种写法
- **WHEN** 用户只要暂存区，该路径的 index 相对 HEAD 有改动，工作区还有未暂存改动
- **AND** 同一次调用用两种折成同一仓库相对路径的写法传入该路径，例如 `./f.txt` 与 `f.txt`
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 返回后工作区 MUST 仍包含调用前的未暂存改动
- **AND** 未暂存改动 MUST NOT 从工作区消失

#### Scenario: 子目录中按 hunk 提交
- **WHEN** 当前目录不是仓库根，路径参数相对该当前目录
- **AND** `--hunks` 补丁是该路径相对 HEAD 的 diff 的完整 hunk 子集
- **THEN** 该次调用 MUST 创建 commit
- **AND** 新建 commit 中该文件 MUST 只含选中的 hunk
- **AND** 未选中的 hunk MUST 仍留在工作区

#### Scenario: 暂存的符号链接在工作区已是普通文件
- **WHEN** 用户只要暂存区，index 中该路径为 `120000`，工作区中该路径已是普通文件
- **THEN** 新建 commit 中该路径 MUST 为 `120000`，链接目标 MUST 等于 index blob 的内容
- **AND** 返回后工作区中该路径 MUST 仍是调用前的普通文件

#### Scenario: 已暂存的可执行文件在工作区被删掉
- **WHEN** 用户只要暂存区，index 中该路径为 `100755`，工作区中该路径不存在
- **THEN** 新建 commit 中该路径 MUST 为 `100755`，内容 MUST 等于 index blob
- **AND** 返回后工作区中该路径 MUST 仍然不存在

#### Scenario: 工作区文件存在但模式与 index 不同
- **WHEN** 用户只要暂存区，index 中该路径为 `100755`，工作区中该路径是模式为 `100644` 的普通文件，且仍有未暂存内容
- **THEN** 新建 commit 中该路径 MUST 为 `100755`
- **AND** 返回后工作区文件的内容与模式 MUST 与调用前一致

#### Scenario: 符号链接两边目标不一致
- **WHEN** index 中该路径是指向目标 B 的符号链接，工作区中该路径仍是指向目标 A 的符号链接，且用户只要暂存区
- **THEN** 新建 commit 中该路径 MUST 为指向 B 的符号链接
- **AND** 目标 A 与目标 B 的内容 MUST 与调用前一致
- **AND** 返回后工作区中该路径 MUST 仍指向 A

#### Scenario: 悬空符号链接
- **WHEN** 工作区中该路径是指向不存在路径的符号链接，且 index 相对 HEAD 有可提交的改动
- **THEN** 该次调用 MUST 能创建 commit，commit 中该路径的模式与 blob MUST 等于 index
- **AND** MUST NOT 创建链接目标
- **AND** 返回后工作区 MUST 仍是调用前的悬空符号链接
