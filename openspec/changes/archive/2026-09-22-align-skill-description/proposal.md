## Why

`SKILL.md` frontmatter `description` 第一句仍是「自动分析 git **staged** 变更，或将整个未提交工作树拆分为多条」，和正文默认路由不一致。目录层 agent 可能只看 `git diff --cached`，漏掉 unstaged / untracked；预览里没有的路径，后面的 `--only` 与密钥门禁都救不回来。

## What Changes

- `description` 的 WHAT MUST 与正文路由对齐：默认分析整棵未提交工作树，先出示预览再按逻辑分批提交；仅当用户明确要求合为一条时走 single。MUST 点到 cz-emoji shortcode、必写 `(scope)`、subject 默认简体中文。
- `description` MUST NOT 把 staged 写成主输入，也 MUST NOT 用「分析 staged，或拆工作树」这种并列。
- WHEN 触发短语保持现有列表（含技能名 `mxcat-commit`），不为了和其它 commit 技能区分而增删触发词。
- `description` MUST NOT 展开确认词表、`--only` 命令或密钥名单。
- 顺手改 `SKILL.md` 引用表里 single 那行「staged 分析」，避免正文自己再暗示只看暂存区。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-packaging`: `description` 必须描述真实默认输入与分流，且不得把 staged 写成主输入。

## Impact

- 修改 `skills/mxcat-commit/SKILL.md` 的 YAML `description`，以及引用表中 single-commit 的摘要用词。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该对齐。
- 不改 single / batch 执行步骤、预览门禁、提交命令或密钥分类。
- 不新增脚本、测试套件或 Python 依赖。
