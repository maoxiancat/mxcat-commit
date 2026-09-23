## Why

路径锁、空行、header 和禁页脚现在都写在文档里，由 agent 在 `git commit` 成功之后再 grep。漏写 `--only` 时，普通 `git commit` 会把 index 里其它已暂存路径一起提交；消息不合法时，对象已经在 HEAD 上。需要一个提交前就会拒绝的单条入口，而不是把整套分批执行器搬回来。

## What Changes

- 技能包提供 `scripts/validate` 与 `scripts/commit_one`。确认后的每一条 commit MUST 经 `commit_one` 创建。消息从本次调用的标准输入读入，MUST NOT 写入固定共享路径（包括 `/tmp/commit_msg.txt`）。
- `validate` 在创建 commit 之前检查 header、分隔空行和禁止页脚。不通过则 MUST NOT 创建该条 commit。
- `commit_one` 只提交调用参数里的路径，并始终使用 `--only`。其它已暂存路径留在 index。默认整棵工作树时只对这些路径 `git add --`；只要暂存区且这些路径仍有未暂存改动时，在提交前停止。
- 提交成功后由 `commit_one` 用 `git show` 对照参数路径。对不上则该次调用失败，已成功的 commit 保留，不自动 reset。
- 尚未进入 HEAD 的密钥、凭证与个人信息仍编进预览并提醒，确认后仍可提交。脚本不维护硬名单，也不把这类路径排除出默认批次。
- 用临时 git 仓库测试路径隔离、非法消息不创建 commit，以及只要暂存区时的硬停。
- 不引入批次执行器、plan 文件、独立 index、shadow worktree 或 secret scanner。分组、预览、确认与回执仍由 agent 按文档完成。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 每条 commit 必须经 `commit_one` 创建；消息仍来自本次标准输入；路径锁、暂存区硬停与文件集合对照收进该入口。
- `mxcat-commit-message-convention`: header、分隔空行与禁止页脚改由提交前的 `validate` 判定；不通过时不创建该条 commit。
- `mxcat-commit-packaging`: 技能目录必须带上这两个脚本，使 `npx skills` 安装结果包含可执行入口。

## Impact

- 新增 `skills/mxcat-commit/scripts/validate`、`skills/mxcat-commit/scripts/commit_one`，以及 `skills/mxcat-commit/tests/` 下的临时仓库测试。
- 修改 `references/single-commit.md`、`references/batch-commit.md` 的提交样例与自检步骤，以及 `references/troubleshooting.md` 里对应的失败说明。
- `SKILL.md` 只点到入口，不展开命令。预览门禁、固定收尾、密钥提醒与回执结构不变。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不新增 Python 依赖。脚本为 shell。
