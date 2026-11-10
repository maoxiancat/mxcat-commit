# 异常恢复规范

- 仅在需要撤回 commit、无法按 hunk 进行提交、提交成功但内容与预览不一致，push 失败时读取本文。不要在无异常发生时读取本文。

## 撤回 commit 

- 需要撤回已提交但未 push 的 commit 时，使用 `git reset --soft` 进行撤回。不要 `git restore`。
- 需要撤回已提交且已 push 的 commit 时，应和用户说明并等待用户确认再确定使用 `git revert` 还是 
`git reset --soft + force push`
- 需要撤回已提交且已 push 的 commit ，本地工作区还进行会与撤回产生冲突的更改时，应和用户说明并按照用户的要求进行操作

## hunk

- 同一文件按预览标明的 hunk 提交时，以本批开始时保留的 git diff HEAD 为准。该结果与预览记录不一致、路径是二进制、是 rename 或 copy 同时还要拆内容，或路径尚未进入 HEAD 时，停止后续提交并说明原因。

## 提交后与预览不一致

- commit 已经提交成功，但实际提交的内容与该条预览不一致时，不要 `git push`，不要用成功开头，并向用户进行说明。

## push 失败

- commit 提交已成功需要进行 push 但 push 失败时，向用户说明无法 push 的原因。
- 不要自行 `git push -u`、`--force` 或 `--force-with-lease`。
