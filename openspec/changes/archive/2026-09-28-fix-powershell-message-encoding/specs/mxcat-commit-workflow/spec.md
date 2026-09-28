## MODIFIED Requirements

### Requirement: 文档中的 PowerShell 调用 MUST 把生成的说明原样写入 commit
技能在 Windows PowerShell 上创建 commit 时，MUST 在同一次进程内把本次生成的整段说明送入 `commit_one.ps1`。承载这段说明的命令文本 MUST 只含 ASCII：整段说明以 UTF-8 字节的 Base64 写在命令里，进进程后再解码成字符串，然后经管道送入入口。MUST NOT 把含非 ASCII 字符的说明明文写进命令文本，也 MUST NOT 把说明字节管道给第二个 `powershell -File`。说明含简体中文或其他非 ASCII 字符时，新建 commit 的说明 MUST 与生成的那段文字一致。MUST NOT 把这段文字写成问号，也 MUST NOT 写成把 UTF-8 字节按系统 ANSI 或 OEM 代码页（含 GBK）解码后的文字。第一行仍匹配 header 骨架 MUST NOT 代替这项一致。管道中已有字符串时，`commit_one.ps1` 与单独运行的 `validate.ps1` MUST 使用这份字符串。管道为空且标准输入被重定向时，二者 MUST 仍按无 BOM 的 UTF-8 读取原始字节。shell 版入口按字节读取标准输入的行为 MUST 保持不变。

#### Scenario: 简体中文说明原样进入 commit
- **WHEN** 按技能文档中的 Windows PowerShell 调用，把含简体中文标题和正文的合格消息送入 `commit_one.ps1`，且路径可以提交
- **THEN** 新建 commit 的说明 MUST 与生成的那段文字一致
- **AND** MUST NOT 是问号替换或 GBK 误读后的文字

#### Scenario: 命令文本按代码页 936 解析时说明仍原样
- **WHEN** Windows PowerShell 5.1 按代码页 936 解析本次命令文本，命令里的说明是「增加」对应 UTF-8 的 Base64，且路径可以提交
- **THEN** 新建 commit 的说明 MUST 仍是「增加」
- **AND** MUST NOT 是把这串 UTF-8 按 GBK 解码得到的「澧炲姞」

#### Scenario: 管道中的字符串优先于标准输入里的其它字节
- **WHEN** 同一次进程把合格说明作为管道中的字符串送入 `commit_one.ps1`，且该进程的标准输入里还有其它字节
- **THEN** 入口使用的说明 MUST 是管道中的那份字符串
- **AND** MUST NOT 改用标准输入里的其它字节

#### Scenario: 管道为空时 UTF-8 字节仍按 UTF-8 进入 commit
- **WHEN** 管道没有字符串，父进程以 UTF-8 把含简体中文的合格消息写入被重定向的标准输入，且路径可以提交
- **THEN** 新建 commit 的说明 MUST 等于这段中文
- **AND** MUST NOT 等于把这些 UTF-8 字节按 GBK 解码得到的文字

#### Scenario: validate.ps1 单独读取同一调用
- **WHEN** 用与 `commit_one.ps1` 相同的文档调用，把含简体中文的合格消息送入单独运行的 `validate.ps1`
- **THEN** 检查所用的消息文本 MUST 与生成的那段文字一致
- **AND** 合格消息 MUST 以 0 退出

## ADDED Requirements

### Requirement: PowerShell 提交成功后 MUST 用码点对照生成的说明
Windows PowerShell 上入口以 0 退出后，技能 MUST 在同一进程内读取新建 commit 的说明，并把每个 Unicode 码点打成 ASCII 十六进制，再与本次生成并送入入口的那段文字的码点对照。对照前两侧 MUST 各去掉末尾的一个换行；中间的空行 MUST 保留。不一致时技能 MUST 停止后续预定 commit，MUST NOT 输出成功回执，MUST NOT 执行 `git commit --amend`。代码页 936 的屏幕把正确说明显示成错字 MUST NOT 代替这项码点对照。shell 版入口的现有自检 MUST 保持不变。

#### Scenario: 码点与生成的文字一致
- **WHEN** 入口以 0 退出，且新建 commit 的说明在去掉末尾一个换行后，码点与本次生成的文字相同
- **THEN** 本项对照 MUST 通过
- **AND** 「增加」的码点 MUST 是 `589E 52A0`

#### Scenario: 写入的是 GBK 误读
- **WHEN** 入口以 0 退出，但新建 commit 的说明是把生成文字的 UTF-8 字节按 GBK 解码的结果
- **THEN** 技能 MUST 停止
- **AND** MUST NOT 输出成功回执
- **AND** MUST NOT 执行 `git commit --amend`
- **AND** 「增加」被误读后的码点 `6FA7 70B2 59DE` MUST 判为不一致

#### Scenario: 屏幕显示成错字但码点仍是原文
- **WHEN** 控制台代码页是 936，入口以 0 退出，且 commit 对象里的码点仍是本次生成的文字
- **THEN** 本项对照 MUST 通过
- **AND** MUST NOT 因屏幕上的错字停止
