## Why

规范要求 `scope` 必写，但选词只有一句「模块、目录或功能面，短词，不要空格」。自检正则 `\([^)]+\)` 只验括号非空，`(my scope)` 也能过。生成靠自觉，机器拦不住规范已经禁止的空格。

## What Changes

- 硬门：括号内 MUST NOT 含空白；标题仍只允许一个 `(scope)`，MUST NOT 写成 `(auth,api)`。自检正则改为拒绝空白。
- 选词（生成时，自检不验语义）：一个小写英文短词；连字符只保留名字里已有的；按这条 commit 的主语在产品面 / 共享层 / 工具链里选，不拼路径、不写允许名单。宿主 skill 快照用 `(skills)`，只改某一个 skill 用包名。看不出主面则拆 commit，不要 `(misc)` / `(all)` / `(update)` / `(wip)`。
- 不把 kebab 字符集、最短长度或斜杠写成硬门。`SKILL.md` 最小硬结果仍只写必写 `(scope)`。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-message-convention`: scope 禁止空白与并列；生成时按主语选一个小写英文短词。

## Impact

- 修改 `references/commit-convention.md` Header（选词规则与反例）和错误示例。
- 修改 `references/single-commit.md` 标题自检正则；batch 复用同一自检。
- `references/troubleshooting.md` 标题不合规补一句：括号内空白也算失败。
- `SKILL.md` 不展开选词。
- `skills/mxcat-commit/CHANGELOG.md` 记录该约束。
- 不新增脚本或测试套件。
