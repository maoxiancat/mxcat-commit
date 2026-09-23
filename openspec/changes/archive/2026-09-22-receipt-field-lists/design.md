## Context

技能仍是文档约束 agent：成功回执是 `references/single-commit.md` / `references/batch-commit.md` 第 7 步的带槽位样例，`SKILL.md` 只留一句换行说明。见 `proposal.md` 的 Why。不改提交命令、确认词或固定收尾。

## Goals / Non-Goals

**Goals:**

- 把字段组换行从 `<br>` 换成 agent 抄得见、CommonMark 到处能折行的无序列表。
- 正式样例改成 list，与现有三套路径对齐；batch 多条重复 Commit 组。

**Non-Goals:**

- 不改字段集合、三套开头、GitHub / 非 GitHub 措辞。技能正文不额外强调禁写 `远程：` 或不要用 `<br>`。
- 不为无 origin、省略仓库地址、工作区不干净、有删除行、push 失败等变体新增整套围栏。
- 不引入回执脚本或模板引擎。

## Decisions

### Decision: 组内用无序列表，标签保留

每项 `- Commit： …`、`- 标题： …`、`- 变更： …`（push 时 `- 分支： …`、`- 仓库地址： …`）。开头句与工作区句仍是段落。组与组之间（含 batch 两条 Commit 块之间）空一行。

CommonMark 会把中间空一行的两组当成同一张松散列表，空行变成间距。不另套 `## commit N` 或嵌套编号，避免和预览标题长出第三套序号。

Alternatives considered:

- 代码块：换行最硬，但字段进围栏、人话留外面会一块聊天一块终端；整张回执进围栏又丢掉对话感。
- 行末两空格：观感最像现在，但空白不可见，存盘、lint、agent 抄写、聊天 trim 都会静默丢掉，回执又黏成一段。
- 行末反斜杠：比两空格好审，仍可能被个别渲染器忽略，行尾 `\` 也像续行符。

### Decision: 正式样例只改现有围栏

single 三条路径、batch 多条只提交、以及 troubleshooting 里「可用提交已完成回执」那句，把 `<br>` 换成 list。无 origin / 非 GitHub / 省略 URL 等继续用旁边的一句话说明。

## Risks / Trade-offs

- [Risk] agent 漏写 `- `，相邻行再次折成一段。  
  Mitigation: 样例每行都以 `- ` 起头；`SKILL.md` 那句与 spec 同步改成「组内写成列表」。

- [Risk] batch 两组 Commit 在渲染里看起来像一张六项清单。  
  Mitigation: 组间空一行，接受松散列表的间距；不引入新编号。

- [Trade-off] 每行多一个项目符号，不如现在「三行紧贴」。  
  Mitigation: 换行稳定优先于无前缀；不要为观感退回 HTML。

## Migration Plan

1. 改 `SKILL.md` 回执换行那句。
2. 改 single / batch 第 7 步说明与围栏样例。
3. 改 troubleshooting 对应一句。
4. CHANGELOG 记呈现调整；不改已发布版本条目正文。
5. 回滚即还原上述 markdown。
