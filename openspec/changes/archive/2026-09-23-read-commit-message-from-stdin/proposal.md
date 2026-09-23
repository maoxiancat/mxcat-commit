## Why

`single-commit.md` / `batch-commit.md` 把提交消息写到固定的 `/tmp/commit_msg.txt`，再 `git commit --file` 去读。这是共享路径：并行 agent、上次残留，或下一条 `printf` 没写成就提交时，会把别的消息提交上去。自检只看标题、空行和禁页脚，对不出「这是上一条的正文」。

## What Changes

- single 与 batch 确认后的提交消息 MUST 由本次 `git commit` 的标准输入经 `--file -` 读入。样例保持 `printf '%s\n'`，空行仍用 `''` 显式写出，再管道给 `git commit --file - --only -- <路径>`。
- MUST NOT 把消息写到固定共享路径（包括 `/tmp/commit_msg.txt`）。
- batch 每一条 commit MUST 使用自己的管道，MUST NOT 复用上一条的消息来源。
- 不改消息正文规则，不改成多个 `-m`，不引入执行器或临时文件清理脚本。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 提交消息必须来自本次 `git commit` 的标准输入；禁止固定共享路径；batch 每条使用自己的管道。

## Impact

- 修改 `references/single-commit.md` 第 5 步两处样例、`references/batch-commit.md` 第 5 步样例，以及 `references/troubleshooting.md` 里重写消息的提示。
- `SKILL.md` 与 `commit-convention.md` 不展开命令写法。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该缺陷修复。
- 不新增脚本、测试套件或依赖。
