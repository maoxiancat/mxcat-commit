# 流程规范

## 1. 了解概况

- `git status --short` 了解工作区概况。

## 2. 确认输入范围

- 默认为整棵未提交工作树（staged + unstaged + untracked）。
- 用户明确要求只提交某部分，则只出示该部分的预览以及提交该部分的 commit。
- 若输入范围内没有任何变更，停止并说明；不要擅自 `git add`。

## 3. 只读分析

- 该阶段只允许只读命令，例如：`git status`、`git diff`、`git log`、`git show` 等。禁止改 index、HEAD、工作区
- 分批时按 [batch-commit.md](batch-commit.md) 中的规范做语义分组，每条 commit 须语义自洽，且能独立构成一条合法、完整的提交消息。
- 起草 commit 标题和内容时遵守 [commit-header.md](commit-header.md)、[commit-body.md](commit-body.md)中的规范。
- 出预览前按 [security-reminder.md](security-reminder.md) 处理这次提交中出现的密钥、个人信息等可能涉及隐私问题的部分（在预览的同时进行提醒）。

## 4. 出示预览

- 按照 [preview.md](preview.md) 中的规范输出分析定稿后的拟提交 commit 预览。
- 禁止在给出预览同时提交或 push commit

## 5. 等待确认或改稿

- 更改标题/内容、合并/拆分条目、丢掉条目时，根据 [preview.md](preview.md) 相关部分进行处理。
- 仅陈述语气的确认算批准提交。
- 禁止在改稿之后直接提交或 push commit，需将改稿之后的内容再次作为预览输出并让用户确认

## 6. 确认后经入口提交

- 在用户批准提交之后，根据 [commit-push.md](commit-push.md) 中的规范以及用户的具体要求进行对应的操作
- 需要 push 时，仅在本次将提交的 commit 均提交完毕后再进行统一 push，任意一条 commit 提交失败，则停止后续操作并且把已提交 commit 撤回

## 7. 成功回执

- 在 commit 提交/push 成功后根据 [success-response.md](success-response.md) 中对应的规范进行输出。

## 8. 异常与恢复

- 在遇到异常时根据 [recovery.md](recovery.md) 中的规范进行处理，如无相关部分则自行判断并处理。
