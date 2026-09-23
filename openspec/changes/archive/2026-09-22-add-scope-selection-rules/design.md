## Context

技能仍是文档约束 agent。标题骨架、必写 `(scope)`、默认中文 subject 已在 `mxcat-commit-message-convention`。见 `proposal.md` 的 Why。本次只加 scope 的硬门与选词；不改提交命令、预览门禁或语言规则。

## Goals / Non-Goals

**Goals:**

- 在 `commit-convention.md` 把选词写成可执行的几条，并补空格 / 并列 / 占位词反例。
- 自检正则只兑现「括号内无空白」；选对不对靠生成规则，不靠字符集门禁。
- `SKILL.md` 最小硬结果不展开选词。

**Non-Goals:**

- 不把 kebab 字符集、最短长度、斜杠或大写写成自检失败。
- 不维护 `home|vote|styles|…` 允许名单。
- 不改 `--only`、预览确认词、密钥提醒或 changelog 条目格式技能。

## Decisions

### Decision: 硬门只禁空白和并列，选词留在生成侧

规范已经写了「不要空格」，自检却用 `\([^)]+\)` 放行 `(my scope)`。收成 `\([^)\s]+\)` 即可兑现这句话。并列 `(auth,api)` 与「一个主语」冲突，用规范禁止，不必再改正则（逗号不含空白，正则仍会过；生成不得写出）。

不收成 `[a-z0-9]+(-[a-z0-9]+)*`：真实仓库好例子虽是单英语词，但没有证据要拦 `(app/ui)`、`(CI)`、`(v2)`。最短长度同理，不专门打 `(a)`。

Alternatives considered:

- 只补启发式、不改正则：`(my scope)` 提交后仍过，和「不要空格」不一致。
- kebab 硬门：这批样本刚好能过，会误伤尚未出现、也未被禁止的形态。

### Decision: 按主语三桶选词，不按目录、不写名单

选词视角是「同事会用哪个词滤 `git log`」，不是顶层目录名。三桶足够：产品面 / 共享层 / 工具链。示例用 `home`、`styles`、`openspec` 说明形态，明确它们不是词表。

连字符只保留源名字里已有的（`(mxcat-commit)`）。不要鼓励把功能说明收成 `(preview-gate)`。

宿主一批 skill 快照用 `(skills)`，与产品仓库既有习惯一致；只改某一个 skill 用包名，与本仓库 dogfood 一致。靠这条 commit 的主语区分，不靠检测脚本。

Alternatives considered:

- 目录名优先：`(i18n)` / `(webview)` 往往不是顶层目录。
- 一律 `(skills)` 或一律包名：和产品仓快照、本仓单 skill 两条历史都会打架。
- 允许词表：换仓库立刻全错。

### Decision: 选词写在 convention，自检写在 single，SKILL 不展开

`commit-convention.md` 是消息真源。`single-commit.md` 第 6 步改那一条 grep；batch 已写「做与 single 相同的自检」。troubleshooting「标题不合规」补括号内空白。`SKILL.md` 继续只说必写 `(scope)`，避免路由器层膨胀。

## Risks / Trade-offs

- [Risk] 无名单、靠判断，不同 agent 对同一 diff 可能选 `(home)` 或 `(styles)`。  
  Mitigation: 以该条主语为准；预览解释必须写「为何这个 scope」，用户可改稿。

- [Risk] 正则不拦逗号、斜杠、中文，生成若漏看选词规则仍能提交。  
  Mitigation: 硬门只兑现空格；并列和中文靠规范与反例。升级字符集属于另一次 change。

- [Trade-off] `(app/ui)` 自检通过。  
  Mitigation: 生成规则要「一个短词」；不把它升级成门禁。

## Migration Plan

1. 扩写 `commit-convention.md` Header 与错误示例。
2. 改 `single-commit.md` 标题自检正则；troubleshooting 补空白失败。
3. CHANGELOG 记录 scope 选词与禁空格自检。
4. 回滚即还原上述 markdown。
