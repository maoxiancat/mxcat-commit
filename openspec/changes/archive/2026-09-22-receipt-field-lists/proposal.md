## Why

成功回执用行末 `<br>` 折行，依赖聊天客户端吃 HTML。CommonMark 会把相邻行折成一段；不支持 raw HTML 的客户端会露出标签或重新黏成一段。

## What Changes

- `Commit：` / `标题：` / `变更：` 与 `分支：` / `仓库地址：` 组内改为 Markdown 无序列表，每项一行，组内不要空行。
- 标签、全角冒号、三套开头语、组与组之间空一行，全部保留。技能正文只写正向规则（写成列表），不要额外强调禁写 `远程：` 或不要用 `<br>`。
- 开头句与工作区句仍是普通段落，不要写成 list。
- 正式样例仍覆盖：只提交（single 一条、batch 多条）、提交并 push、提交之后再 push。其余变体（无 origin、非 GitHub、省略仓库地址、工作区不干净、有删除行、push 失败套「提交已完成」）靠既有说明，不新增整套围栏。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-workflow`: 回执字段组内用 Markdown 列表换行，不再用 `<br>`。

## Impact

- 修改 `SKILL.md` 预览门禁里那句回执换行说明。
- 修改 `references/single-commit.md`、`references/batch-commit.md` 第 7 步文字与样例。
- 修改 `references/troubleshooting.md` 里「提交已完成」回执的换行说明。
- 在 `skills/mxcat-commit/CHANGELOG.md` 记录该呈现调整。
- 不新增脚本；不改提交命令、预览门禁确认词或固定收尾原文。
