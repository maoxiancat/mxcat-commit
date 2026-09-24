## ADDED Requirements

### Requirement: 未创建 commit 的失败 MUST 把 index 恢复到调用前
`commit_one` 在第一次改变 index 之前 MUST 记住调用时的 index。该次调用没有创建 commit 时，退出前 MUST 把 index 恢复成调用时的内容，MUST NOT 移动 HEAD。成功创建 commit 之后，index MUST 保持 `git commit` 留下的结果，MUST NOT 放回调用前。提交后的文件集合或 hunk 对照失败时，已创建的 commit MUST 保留，MUST NOT 自动 `reset`。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 夹带未改动文件时 index 回到调用前
- **WHEN** `--add` 的路径里除本次有差异的文件外，还包含一个相对 HEAD 与 index 都没有差异的文件
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** index MUST 与调用前一致

#### Scenario: git add 失败时已暂存的路径也被放回
- **WHEN** `--add` 的路径里包含一个有差异的文件和一个被忽略的文件，且 `git add` 非 0 退出
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** 那个有差异的文件在 index 中 MUST 与调用前一致

#### Scenario: 工作区回到 HEAD 时不盖掉 index 里的另一版
- **WHEN** 某路径的工作区内容与 HEAD 相同，index 中该路径的 blob 与 HEAD 不同，且对该路径使用 `--add`
- **THEN** 该次调用 MUST 非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** index 中该路径的 blob MUST 仍是调用前的 blob

#### Scenario: hook 拒绝时 index 回到调用前
- **WHEN** `git commit` 因 hook 非 0 退出
- **THEN** MUST NOT 创建 commit
- **AND** index MUST 与调用前一致
- **AND** HEAD MUST 仍是调用前的 commit

#### Scenario: 成功提交后不放回调用前的 index
- **WHEN** `commit_one --add` 成功创建 commit
- **THEN** 该路径在 index 中的 blob MUST 等于新建 commit 中的 blob
- **AND** 未列入本次路径、调用前已暂存的其它路径 MUST 仍留在 index 中

#### Scenario: 提交后对照失败时保留 commit 与提交后的 index
- **WHEN** `git commit` 已经创建 commit，随后文件集合或 hunk 对照失败
- **THEN** 该次调用 MUST 非 0 退出
- **AND** 该 commit MUST 仍是 HEAD
- **AND** MUST NOT 自动 `reset`
- **AND** 已提交路径在 index 中的 blob MUST 等于该 commit，而不是调用前的 blob
