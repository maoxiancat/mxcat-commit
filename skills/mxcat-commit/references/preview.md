# 预览规范

## 预览门禁

- 禁止在给出预览同时提交或 push commit
- 尚未出示预览时，提交、帮我提交、可以提交、提交并 push、commit、commit and push 等描述一律只分析变更、出示预览
- 仅当用户明确要求跳过预览时才不出示预览并进行提交/push
- 用户对预览进行确认过后才依照 [commit-push.md](references/commit-push.md) 中的规范进行下一步
- 仅陈述语气的确认算批准提交/push。
- 禁止在改稿之后直接提交或 push commit，需将改稿之后的内容再次作为预览输出并让用户确认
- 该阶段只允许只读命令，例如：`git status`、`git diff`、`git log`、`git show` 等。禁止改 index、HEAD、工作区
- 改稿之后需重出整单预览并等待用户再次确认

## 预览内容要求

- 分批时按 [batch-commit.md](batch-commit.md) 中的规范做语义分组，每条 commit 须语义自洽，且能独立构成一条合法、完整的提交消息。
- 起草 commit 标题和内容时遵守 [commit-header.md](commit-header.md)、[commit-body.md](commit-body.md)中的规范。
- 出预览前按 [security-reminder.md](security-reminder.md) 处理这次提交中出现的密钥、个人信息等可能涉及隐私问题的部分（在预览的同时进行提醒）。
- 每个拟提交 commit 的预览分为四部分(序号、标题、正文、解释)，每部分之间保留一个空行
- 预览输出形式
```text
## commit N

标题
:type: (scope) subject

正文
- xxxxxxxx
- xxxxxxxx

解释
- :type: 解释为什么使用这个 type
- scope 解释为什么使用这个 scope
```

## 预览固定收尾

- 在全部预览条目之后保留一个空行，原样输出：尚未提交/push commit，请回复「提交」「提交并 push」等进行提交、push，如要改稿，请直接说明需要做的改动，将重出整单预览

## 示例

示例前提：两条 commit 语义分开。`src/charts/LineChart.tsx` 已在 HEAD 中，两条各占有 `git diff HEAD` 里的一个完整 hunk，行号互不重叠。没有密钥或个人信息，不加提醒块。

```text
## commit 1

标题
:sparkles: (charts) 增加空数据占位

正文
- 折线图没有数据点时展示占位
- 占位沿用当前图表的宽高

解释
- :sparkles: 新增空数据展示，属于新功能
- charts 改动范围只有图表展示

## commit 2

标题
:bug: (charts) 修复横轴刻度重叠

正文
- 数据点较多时横轴标签不再叠在一起
- 刻度间隔按容器宽度计算

解释
- :bug: 修正横轴刻度重叠，属于缺陷修复
- charts 改动范围只有图表坐标轴

尚未提交/push commit，请回复「提交」「提交并 push」等进行提交、push，如要改稿，请直接说明需要做的改动，将重出整单预览
```

示例前提：`.env` 尚未进入 HEAD，仍编进对应条目。提醒放在全部条目之后、固定收尾之前。

```text
## commit 1

标题
:wrench: (local) 纳入本地环境变量文件

正文
- 把本地环境变量文件纳入版本库

解释
- :wrench: 只增加本地配置文件，不改程序行为
- local 范围是本地环境配置

提醒
- `.env` 看起来含有密钥/凭证，且从未进过仓库。

尚未提交/push commit，请回复「提交」「提交并 push」等进行提交、push，如要改稿，请直接说明需要做的改动，将重出整单预览
```
