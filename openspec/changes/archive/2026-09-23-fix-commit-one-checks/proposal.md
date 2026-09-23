## Why

`validate` 会放行三类不合规消息：标题和正文粘在一起、但后面另有空行；行首带空白的禁止页脚；`(auth,api)` 这种并列 scope。`commit_one` 则在 `git commit` 成功之后才对照路径，`./`、非仓库根目录下的相对路径会误报失败，目录参数和未改动文件则会在 commit 已经写入 `HEAD` 之后才退出。不合规消息会进历史，调用方也会看到失败、但提交已经存在。

## What Changes

- `validate` 在标题之后、第一处空行之前若已出现非空行，必须拒绝。后面的空行（例如 `BREAKING CHANGE:` 之前）不能把粘连洗白。只有标题、标题后先空行再正文、多一个分隔空行仍然通过。正文与 `BREAKING CHANGE:` 之间少空行，仍然不因此失败。
- `validate` 去掉行首空白后再判断禁止页脚。` Co-authored-by:`、`AI-Co-Authored-By:`、`Jira-Refs:` 必须拒绝。
- `validate` 的 `(scope)` 必须是单个小写 token（可含连字符）。`(auth,api)` 必须拒绝。
- `commit_one` 对照文件集合前，把参数和 `git show` 的路径收成同一种仓库相对路径（去掉 `./`，按当前目录补前缀）。写法不同但指向同一文件时，自检通过。
- 参数是目录，或某条路径相对 `HEAD` 没有差异时，必须在 `git commit` 之前退出，不创建 commit。
- 提交之后的对照仍然保留。真对不上时不自动 `reset`，已成功的 commit 保留。
- 不改消息来源：仍从本次标准输入读入，不写 `/tmp/commit_msg.txt`。
- 不处理这三件既有约定：`git mv` 之后再 `--add` 旧路径、重命名只传新路径、hook 拒绝后 `--add` 留下的暂存。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-message-convention`: 提交前检查必须拒绝「标题后先出现非空行」、行首带空白的禁止页脚，以及并列 scope。
- `mxcat-commit-workflow`: 路径对照必须先规范化；目录和未改动路径必须在创建 commit 之前失败。

## Impact

- 修改 `skills/mxcat-commit/scripts/validate`、`validate.ps1`、`commit_one`、`commit_one.ps1`。sh 与 PowerShell 规则保持一致。
- 修改 `references/troubleshooting.md` 里空行失败与路径对照失败的说明，使「粘连但后面有空行」和「提交前预检失败、commit 未创建」与脚本一致。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不新增依赖，不改预览门禁、回执结构或密钥路径策略。
