## ADDED Requirements

### Requirement: 目录参数或相对 HEAD 无差异的路径 MUST 在创建 commit 之前失败
`commit_one` MUST 在调用 `git commit` 之前判断路径参数能否原样成为该次 commit 的文件集合。任一参数在调用时是目录，或规范化之后相对 `HEAD` 没有差异、因而不会出现在该次 commit 中时，该次调用 MUST 非 0 退出，MUST NOT 创建该条 commit。参数都是有差异的文件，且重命名或删除同时给出了旧路径与新路径时，这项预检 MUST NOT 拒绝该次调用。预检使用的路径身份与提交后的文件集合对照相同。

#### Scenario: 目录参数不创建 commit
- **WHEN** `commit_one` 的路径参数包含一个目录，且消息已通过提交前检查
- **THEN** 该次调用 MUST 在 `git commit` 之前非 0 退出
- **AND** MUST NOT 创建该条 commit

#### Scenario: 夹带未改动文件不创建 commit
- **WHEN** 路径参数里除本次有差异的文件外，还包含一个相对 `HEAD` 没有差异的文件
- **THEN** 该次调用 MUST 在 `git commit` 之前非 0 退出
- **AND** MUST NOT 创建该条 commit

#### Scenario: 有差异的文件通过预检
- **WHEN** 每个路径参数都是相对 `HEAD` 有差异的文件，且消息已通过提交前检查
- **THEN** 预检 MUST NOT 拒绝该次调用
- **AND** `commit_one` MUST 继续执行 `git commit`

#### Scenario: 重命名同时给出旧路径与新路径时预检通过
- **WHEN** 路径参数同时包含一次重命名的旧路径与新路径，且两者都会进入该次 commit
- **THEN** 预检 MUST NOT 因旧路径或新路径拒绝该次调用

## MODIFIED Requirements

### Requirement: 提交后 MUST 对照预览路径自检文件集合
`commit_one` 在 `git commit` 成功后，MUST 用 `git show --name-only`（rename 则用 `--name-status`）核对新建 commit 的路径是否等于本次调用的路径参数。比较前 MUST 把两侧路径收成仓库相对路径：去掉 `./`，并按调用时的当前目录补上仓库内前缀。收成同一路径后 MUST 视为一致。对不上时该次调用 MUST 非 0 退出，技能 MUST 视为自检失败：MUST 停止后续预定 commit，MUST 向用户报告实际路径与预览路径，MUST NOT 运行 `git push`，MUST NOT 输出成功回执，MUST NOT 自动 `reset` 已成功的 commit。

#### Scenario: 文件集合与预览一致
- **WHEN** 新建 commit 的路径与该次 `commit_one` 的路径参数在规范化之后一致
- **THEN** 技能 MUST 将本项自检视为通过
- **AND** 若其它自检也通过，可继续下一条或进入成功回执

#### Scenario: 带 ./ 前缀仍视为一致
- **WHEN** 路径参数为 `./` 加上仓库相对路径，且新建 commit 包含去掉该前缀后的同一路径
- **THEN** 文件集合对照 MUST 通过
- **AND** `commit_one` MUST 以 0 退出

#### Scenario: 非仓库根目录下的相对路径仍视为一致
- **WHEN** 调用 `commit_one` 时当前目录不是仓库根，路径参数相对该当前目录，且新建 commit 包含对应的仓库相对路径
- **THEN** 文件集合对照 MUST 通过
- **AND** `commit_one` MUST 以 0 退出

#### Scenario: 文件集合与预览不一致则停止
- **WHEN** 规范化之后，`git show` 列出的路径与该次 `commit_one` 的路径参数仍不一致
- **THEN** `commit_one` MUST 非 0 退出
- **AND** 技能 MUST 停止后续预定 commit
- **AND** MUST 报告实际路径与预览路径
- **AND** MUST NOT 运行 `git push`
- **AND** MUST NOT 使用成功回执开头
- **AND** 已成功的 commit MUST 保留
