## ADDED Requirements

### Requirement: 文档中的 PowerShell 调用 MUST 把生成的说明原样写入 commit
技能在 Windows PowerShell 上创建 commit 时，MUST 使用会保持消息字符的调用把本次生成的说明送入 `commit_one.ps1`。说明含简体中文或其他非 ASCII 字符时，新建 commit 的说明 MUST 与生成的那段文字一致。MUST NOT 把这段文字写成问号，也 MUST NOT 写成把 UTF-8 字节按系统 OEM 代码页（含 GBK）解码后的文字。第一行仍匹配 header 骨架 MUST NOT 代替这项一致。单独运行的 `validate.ps1` 从同一类调用读到的消息文本 MUST 与生成的那段文字一致。shell 版入口按字节读取标准输入的行为 MUST 保持不变。

#### Scenario: 简体中文说明原样进入 commit
- **WHEN** 按技能文档中的 Windows PowerShell 调用，把含简体中文标题和正文的合格消息送入 `commit_one.ps1`，且路径可以提交
- **THEN** 新建 commit 的说明 MUST 与生成的那段文字一致
- **AND** MUST NOT 是问号替换或 GBK 误读后的文字

#### Scenario: UTF-8 字节管道按 UTF-8 进入 commit
- **WHEN** 父进程以 UTF-8 把含简体中文的合格消息管道给 `commit_one.ps1`，且路径可以提交
- **THEN** 新建 commit 的说明 MUST 等于这段中文
- **AND** MUST NOT 等于把这些 UTF-8 字节按 GBK 解码得到的文字

#### Scenario: validate.ps1 单独读取同一管道
- **WHEN** 用与 `commit_one.ps1` 相同的文档调用，把含简体中文的合格消息送入单独运行的 `validate.ps1`
- **THEN** 检查所用的消息文本 MUST 与生成的那段文字一致
- **AND** 合格消息 MUST 以 0 退出

### Requirement: 换入失败且未创建 commit 时工作区路径 MUST 仍在
按 hunk 提交，或不带 `--add` 只提交 index 内容时，若在创建 commit 之前失败，该路径的工作区类型与内容 MUST 恢复为调用前。无法建立要提交的符号链接时也 MUST 如此。MUST NOT 在退出后留下已被删除的原路径。该次调用 MUST NOT 创建 commit。sh 与 PowerShell 入口 MUST 使用同一规则。

#### Scenario: 符号链接换入失败后原链接还在
- **WHEN** 要提交的条目是符号链接，工作区中该路径已是符号链接，且建立提交用链接失败
- **THEN** 该次调用 MUST 在创建 commit 之前非 0 退出
- **AND** MUST NOT 创建 commit
- **AND** 返回后该路径 MUST 仍是调用前的符号链接，目标与调用前相同

### Requirement: 经目录符号链接进入仓库的绝对路径 MUST 视为仓库内
在 Windows 上，`commit_one.ps1` MUST 先把路径参数中的目录符号链接解析到最终路径，再判断该路径是否在仓库内。同一绝对路径经目录符号链接指向仓库内文件，且 shell 版入口能把它收成仓库相对路径并提交时，PowerShell 入口 MUST 同样提交。MUST NOT 以路径不在仓库内为由在创建 commit 之前拒绝。非 Windows 上的路径解析 MUST 保持不变。

#### Scenario: Windows 上经符号链接目录提交仓库内文件
- **WHEN** 在 Windows 上调用 `commit_one.ps1`，路径参数是经过目录符号链接指向仓库内文件的绝对路径，该文件相对 HEAD 有差异，且消息合格
- **THEN** 该次调用 MUST 创建 commit
- **AND** 该 commit MUST 包含对应的仓库相对路径
- **AND** MUST NOT 以路径不在仓库内为由退出
