## ADDED Requirements

### Requirement: Redirected commit message is UTF-8

当标准输入被重定向时，PowerShell 提交入口 MUST 在枚举 `$input` 之前把原始字节按无 BOM 的 UTF-8 解码为提交说明。入口 MUST NOT 使用宿主按控制台代码页预先解码的 `$input` 字符串作为该说明。写入 Git 的说明 MUST 与这段 UTF-8 文本一致，包括非 ASCII 字符。

#### Scenario: Chinese subject survives the child process

- **WHEN** 父会话将 `$OutputEncoding` 设为无 BOM 的 UTF-8，并把含有「调整首页」的说明管道给 `powershell -NoProfile -File commit_one.ps1`
- **THEN** 新提交的说明含有「调整首页」，这些字符不是 `?`

#### Scenario: Redirected stdin skips pipeline strings

- **WHEN** 标准输入已重定向，且宿主若枚举 `$input` 会按 gb2312 解码
- **THEN** 入口从原始字节按 UTF-8 得到说明，并且不采用那份按 gb2312 解码的字符串

### Requirement: Non-ASCII repository root reaches git -C

PowerShell 提交入口 MUST 在第一次调用 Git 之前将子进程的控制台输出编码设为无 BOM 的 UTF-8，并以此解码 Git 打印的仓库根。随后的 `git -C` MUST 使用该仓库根。仓库根含非 ASCII 字符时，传给 `git -C` 的路径 MUST 仍包含该字符。

#### Scenario: Directory name containing 杂

- **WHEN** 仓库根路径包含「杂」，且 Git 以 UTF-8 打印该路径
- **THEN** `git -C` 使用的路径包含「杂」，而不是这些 UTF-8 字节按 gb2312 解码后的文本

### Requirement: git -C failure aborts before commit

解析仓库根之后，若任一用于准备本次提交的 `git -C <仓库根>` 命令以非零状态退出，入口 MUST 以非零状态退出，且 MUST NOT 创建新的 commit。入口 MUST NOT 把这类失败当成空的暂存信息后继续 `git add` 或 `git commit`。

#### Scenario: Resolved root is not a usable git -C path

- **WHEN** `git -C <解析得到的仓库根>` 失败
- **THEN** 进程以非零状态退出，并且 HEAD 没有新的 commit

#### Scenario: Rename probe failure does not continue

- **WHEN** 改名检测所用的 `git -C` 以非零状态退出
- **THEN** 入口停止，并且没有执行 `git commit`

### Requirement: PowerShell examples set UTF-8 output encoding

`batch-commit.md` 与 `single-commit.md` 中的 Windows PowerShell 示例 MUST 在把说明管道给 `powershell -NoProfile -File commit_one.ps1` 的同一段命令中，将 `$OutputEncoding` 设为无 BOM 的 UTF-8。示例 MUST 仍然通过该子进程调用入口，而不是在当前会话中直接 `&` 脚本。

#### Scenario: Both guides show the encoding assignment

- **WHEN** 读者按 batch 或 single 指南里的 PowerShell 示例提交
- **THEN** 该示例在管道之前把 `$OutputEncoding` 设为无 BOM 的 UTF-8，并使用 `powershell -NoProfile -File commit_one.ps1`
