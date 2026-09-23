## ADDED Requirements

### Requirement: 提交消息 MUST 来自本次命令的标准输入
single 与 batch 在创建每条 commit 时，消息 MUST 经该次 `git commit --file -` 从标准输入读入。产生消息的命令与该次 `git commit` MUST 处于同一条管道。MUST NOT 把消息写入固定共享路径后再用 `--file` 读取（包括 `/tmp/commit_msg.txt`）。header 与 body 之间需要空行时，消息生成 MUST 仍显式给出该空行。batch 每一条 MUST 使用自己的管道，MUST NOT 复用上一条的消息来源。

#### Scenario: 单次提交从标准输入读消息
- **WHEN** 用户已批准提交，且消息含标题、一个空行与 body
- **THEN** 技能 MUST 用本次 `git commit --file -` 从标准输入读入该消息
- **AND** MUST NOT 从固定共享路径读取消息

#### Scenario: 固定路径上已有另一段消息
- **WHEN** `/tmp/commit_msg.txt` 或其它固定共享路径上已有另一段消息，且用户已批准提交
- **THEN** 新建 commit MUST NOT 把该路径用作 `--file` 参数

#### Scenario: batch 每条各自一条管道
- **WHEN** batch 按序创建两条 commit，且两条消息不同
- **THEN** 每条 MUST 使用自己的标准输入管道
- **AND** 第二条 MUST NOT 复用第一条的消息来源
