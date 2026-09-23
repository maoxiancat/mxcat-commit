## Why

`single-commit.md` 第 6 步空行自检只把 `git cat-file -p HEAD` 交给 `cat -vet` 打印，没有通过 / 失败判定。header 正则和禁页脚 `grep` 都能拦，缺 header 与 body 之间的分隔空行却过得去。`cat -vet` 还会把中文打成乱码，Agent 更容易当走过场。

## What Changes

- 提交后空行自检 MUST 可判定：`%B` 在标题后还有非空行时，`%b` MUST 非空；否则该项 MUST 失败并打印 `FAIL`。只有标题时 MUST 通过。
- 检查命令 MUST 使用 `git log` 的 `%B` / `%b`，MUST NOT 再用 `git cat-file` + `cat -vet` 目视。命令 MUST 写成带 `else` 的 `if`，MUST NOT 收成 `&& … || echo FAIL`（只有标题会被误判失败）。
- 生成规则仍要求 header 与 body 之间一个空行；自检门不验「恰好一个」、不验 body 与 `BREAKING CHANGE:` 之间的空行。
- batch 继续复用 single 同一套自检。不引入执行器或测试套件。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-message-convention`: 提交后空行自检必须可判定；标题后还有非空行但 git 解析不出 `%b` 时必须失败。

## Impact

- 修改 `references/single-commit.md` 第 6 步空行检查；batch 已写「做与 single 相同的自检」，不必再写一份。
- `references/troubleshooting.md`「空行丢失」补一句：自检打印 FAIL 时按本节处理。
- `SKILL.md` 与 `commit-convention.md` 不改生成规则，不把检查命令展开上去。
- `skills/mxcat-commit/CHANGELOG.md` 记录该自检。
- 不新增脚本或测试套件。不从授权名单拿掉 `git cat-file`。
