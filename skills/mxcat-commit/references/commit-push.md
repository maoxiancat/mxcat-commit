# commit 提交/push 规范

## commit 提交规范

- 无特殊要求时，提交每一条预览时拟提交的 commit
- 用户要求只提交部分条目时，按原序只提交被要求提交的条目；其余文件留在工作区，不要 restore。
- 按照预览时 commit 的标题/内容以及顺序提交 commit
- 在提交时应检查提交的内容是否与预览的一致，如有不一致则依照新内容再次预览而不是提交 commit
- 同一已跟踪文件出现在多条预览时，每条 commit 只带走对应的 hunk。
- 在按序提交多条 commit 时，任意一条 commit 提交失败，则停止后续操作并且把已提交 commit 撤回(不要 restore)，尝试重新提交，如还是失败则对用户进行说明
- 在提交成功后依照 [success-response.md](success-response.md) 中的内容对用户进行说明

## commit push 规范

- 用户只要求提交，未明确要求 push 时，不要 push commit
- 需要 push 时，仅在拟提交的所有 commit 均提交完毕后再统一进行 push
- 仅 push 预览时拟提交的 commit，不属于预览拟提交的 commit 不 push 并对用户进行提醒
- 无用户明确要求时禁止 force push
- 没有上游时报告原因并停止，不要在没有用户确认时 `git push -u`。
- 如该仓库远程不止一条分支，则在直接 push 到 main/master 分支时需要对用户进行提醒，等用户确认直接 push 到 main/master 才 push
- 在提交成功后依照 [success-response.md](success-response.md) 中的内容对用户进行说明
