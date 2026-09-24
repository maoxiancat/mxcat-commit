## MODIFIED Requirements

### Requirement: 提交 MUST 锁预览路径
single 与 batch 在创建每条 commit 时，MUST 调用当前 shell 对应的入口，并把该条预览列出的仓库相对路径作为它的路径参数。当前 shell 是 sh、bash 或 zsh 时，入口 MUST 是技能目录中的 `scripts/commit_one`。当前 shell 是 Windows PowerShell 时，入口 MUST 是 `scripts/commit_one.ps1`。MUST NOT 在 PowerShell 中调用 `scripts/commit_one`，也 MUST NOT 在 sh 中调用 `scripts/commit_one.ps1`。下文的 `commit_one` 指这次实际调用的入口。该入口 MUST 把这些路径传给 `git commit --only`（或等价的「命令行给出路径」模式）。该 commit 的文件集合 MUST 等于这些路径，MUST NOT 把 index 中其它已暂存路径带进去。未列入该条的已暂存路径在提交后 MUST 仍留在 index。rename 或 delete 时，锁路径 MUST 包含该条预览列出的旧路径与新路径。默认输入为整棵工作树时，对 index 与 HEAD 相同或尚未进入 index 的整文件路径，`commit_one` MUST 先执行 `git add --`，以便纳入 untracked 与仅存在于工作区的改动。index 相对 HEAD 已有改动且工作区还有更多改动的路径，MUST NOT `git add` 工作区全文，MUST 提交 index 中的模式与 blob，未暂存改动 MUST 留在工作区。已暂存 rename 的旧路径已不在工作区、也不在 index 时，MUST NOT 对该旧路径执行 `git add --`；新旧路径都列入参数时，这条 commit MUST 是一次 rename。用户只要暂存区时，对整文件路径 MUST NOT `git add` 未暂存文件。被标为部分提交的已跟踪路径 MUST NOT 先 `git add` 工作区全文，MUST 提交由当前 HEAD 版本加上该条 hunk 得到的 blob；若 index 中该路径的 blob 已等于这个结果，MUST 改提交该 index blob。`commit_one` MUST NOT 因路径名像密钥、凭证或个人信息而拒绝参数中的路径。`--add` 时，一次调用里折成同一仓库相对路径的参数 MUST 只换入一次，恢复 MUST 用调用前的工作区。index 与 HEAD 相同、因此对该路径执行 `git add` 时，重复参数 MUST NOT 取消第一次 `git add`。HEAD 中有、index 与工作区都没有的已暂存删除，`--add` MUST NOT 对该路径执行 `git add`，该 commit MUST 记录这次删除。工作区已删除但 index 仍有该路径时，`--add` MUST 仍对该路径执行 `git add`。删除已暂存且该文件又出现在工作区时，不论是否带 `--add`，该 commit MUST 记录这次删除，后出现的内容 MUST NOT 进入历史，返回后 MUST 仍在工作区。该次调用在创建 commit 之前失败时，MUST 把这个文件放回调用前的内容。已暂存改名不再被识别为 rename、而是删除加新增，且新旧路径都列入参数时，`--add` MUST 创建 commit，MUST NOT 因旧路径匹配不到文件而以非 0 退出。git 仍把这次改动识别为 rename，且参数只有旧路径、新路径不在其中时，不论是否带 `--add`，MUST 在创建 commit 之前退出，MUST NOT 创建删除该旧路径的 commit，index MUST 保持这次改名。git 已把该次改动看成删除加新增时，只传入旧路径 MUST 仍提交这次删除。copy 的旧路径仍在工作区与 index 中时，MUST NOT 按 rename 的旧路径跳过；有未暂存改动时 MUST 只提交 index，否则 MUST 执行 `git add`。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 其它已暂存路径不进入本次 commit
- **WHEN** index 中除预览路径外还暂存了其它文件，且用户已批准按该预览经 `commit_one` 提交
- **THEN** 新建 commit 的文件集合 MUST 仅含该条预览列出的路径
- **AND** 那些未列入预览的已暂存路径 MUST 在提交后仍出现在 index 中

#### Scenario: 丢掉的预览条目即使仍暂存也不被吞入
- **WHEN** 用户不要提交某一预览条目，该条文件仍留在工作区且仍为 staged，随后用户批准经 `commit_one` 提交剩余条目
- **THEN** 剩余条目对应的 commit MUST NOT 包含被丢掉条目列出的路径

#### Scenario: batch 下一条仍只锁本条路径
- **WHEN** batch 预览含两条不同路径，第一条已经 `commit_one` 提交成功，第二条路径仍为 staged
- **THEN** 第二条 commit 的文件集合 MUST 仅含第二条预览列出的路径

#### Scenario: 参数中的密钥路径仍可提交
- **WHEN** 调用 `commit_one` 的路径参数包含尚未进入 HEAD 的 `.env`，且本次消息通过提交前检查
- **THEN** 新建 commit MUST 包含该 `.env` 路径
- **AND** `commit_one` MUST NOT 因该文件名拒绝提交

#### Scenario: sh 调用 shell 入口
- **WHEN** 当前 shell 是 sh、bash 或 zsh，且用户已批准提交
- **THEN** 技能 MUST 调用 `scripts/commit_one`
- **AND** MUST NOT 调用 `scripts/commit_one.ps1`

#### Scenario: Windows PowerShell 调用 ps1 入口
- **WHEN** 当前 shell 是 Windows PowerShell，且用户已批准提交
- **THEN** 技能 MUST 调用 `scripts/commit_one.ps1`
- **AND** MUST NOT 调用 `scripts/commit_one`

#### Scenario: 部分路径不提交工作区全文
- **WHEN** 某已跟踪路径被标为部分提交，且工作区里该文件还含有不属于这条的改动
- **THEN** 新建 commit 中该文件 MUST 只含这条的 hunk
- **AND** 调用返回后该文件的工作区字节 MUST 与调用前一致
- **AND** 同一次调用中的其它整文件路径 MUST 仍按整文件进入该 commit

#### Scenario: 部分暂存时 --add 只提交 index 那一截
- **WHEN** `commit_one --add` 的路径里，某文件的 index 相对 HEAD 已有改动，工作区还有更多改动
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 调用返回后未暂存改动 MUST 仍出现在 `git diff` 中
- **AND** MUST NOT 把工作区全文写入该 commit

#### Scenario: 仅工作区有改动时 --add 仍提交全文
- **WHEN** `commit_one --add` 的路径尚未进入 index，或 index 与 HEAD 相同，且工作区有改动
- **THEN** 新建 commit 中该文件 MUST 等于工作区全文

#### Scenario: 已暂存的改名可以 --add 两个路径
- **WHEN** index 中已是 `old.txt -> new.txt`，且 `commit_one --add` 的路径同时包含旧路径与新路径
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit MUST 是一次 rename
- **AND** MUST NOT 因旧路径匹配不到文件而以非 0 退出

#### Scenario: --add 同一路径两种写法只换入一次
- **WHEN** `commit_one --add` 用两种折成同一仓库相对路径的写法传入同一路径，例如 `./note.txt` 与 `note.txt`
- **AND** 该路径的 index 相对 HEAD 已有改动，工作区还有更多改动
- **THEN** 新建 commit 中该文件的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 返回后工作区 MUST 仍包含调用前的未暂存改动

#### Scenario: 重复参数但 index 与 HEAD 相同时仍暂存工作区
- **WHEN** `commit_one --add` 用两种折成同一仓库相对路径的写法传入同一路径
- **AND** 该路径的 index 与 HEAD 相同，工作区有改动
- **THEN** 新建 commit 中该文件 MUST 等于工作区全文

#### Scenario: 已暂存的删除可以 --add
- **WHEN** 某路径已用删除进入 index，工作区中该路径不存在，且 `commit_one --add` 的参数包含该路径
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit MUST 记录这次删除
- **AND** MUST NOT 因路径匹配不到文件而以非 0 退出

#### Scenario: 尚未暂存的工作区删除仍由 --add 纳入
- **WHEN** 某路径仍在 index 中，工作区中该路径已删除，且 `commit_one --add` 的参数包含该路径
- **THEN** 新建 commit MUST 记录这次删除

#### Scenario: 删除已暂存且文件又出现在工作区
- **WHEN** 某路径的删除已在 index 中，工作区又出现该文件，且对该路径调用 `commit_one`，不论是否带 `--add`
- **THEN** 新建 commit MUST 记录这次删除
- **AND** 后出现的内容 MUST NOT 进入该 commit
- **AND** 返回后工作区 MUST 仍是调用前的该文件

#### Scenario: 挪走后出现的文件之后提交失败
- **WHEN** 删除已暂存且工作区又出现该文件，`commit_one` 在创建 commit 之前失败
- **THEN** MUST NOT 创建 commit
- **AND** 工作区中该文件 MUST 与调用前一致

#### Scenario: 改名不再被识别为 rename 时 --add 两个路径
- **WHEN** 已暂存的 `old.txt` 到 `new.txt` 不再被识别为 rename，而是删除加新增
- **AND** `commit_one --add` 的路径同时包含旧路径与新路径
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit MUST 包含旧路径的删除与新路径的新增
- **AND** MUST NOT 因旧路径匹配不到文件而以非 0 退出

#### Scenario: 只给 rename 的旧路径
- **WHEN** index 中已是 `old.txt -> new.txt`，且 `commit_one` 的参数只有旧路径，不论是否带 `--add`
- **THEN** 该次调用 MUST 在创建 commit 之前退出
- **AND** MUST NOT 创建删除旧路径的 commit
- **AND** index MUST 仍是这次改名

#### Scenario: 相似度不足时只给旧路径仍提交删除
- **WHEN** 已暂存的旧路径到新路径不再被识别为 rename，而是删除加新增
- **AND** `commit_one` 的参数只有旧路径
- **THEN** 新建 commit MUST 记录旧路径的这次删除
- **AND** 新路径 MUST 仍留在 index 中

#### Scenario: copy 的旧路径不按 rename 跳过
- **WHEN** index 中已是某路径复制到另一路径，旧路径仍在工作区与 index 中，且工作区相对 index 还有未暂存改动
- **AND** `commit_one --add` 的路径包含该旧路径
- **THEN** 新建 commit 中该旧路径的 diff MUST 等于 index 相对 HEAD 的 diff
- **AND** 未暂存改动 MUST 仍留在工作区
