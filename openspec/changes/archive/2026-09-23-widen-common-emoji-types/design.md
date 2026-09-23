## Context

技能仍是文档约束 agent。短表在 `references/commit-convention.md`，完整目录在 `references/cz-emoji-types.md`，读取时机写在 `SKILL.md` 的 reference 表。见 `proposal.md` 的 Why。本次只加宽常用类型并改读取条件；不改标题骨架、scope 选词、预览门禁或提交命令。

## Goals / Non-Goals

**Goals:**

- 短表补上界面、代码格式、安全修复、添加依赖，并把 `:wrench:` 收成配置。
- 选词与「必须打开完整表」写在短表旁边；`SKILL.md` 只改读取时机那一格。
- 完整类型目录保持原样，只改开头那句读取条件。

**Non-Goals:**

- 不把完整表展开进 `SKILL.md`。
- 不把文案、依赖升级/移除、CI、国际化再加进短表。
- 不对齐 `cz-emoji-types.md` 自己那节「常用类型」（15 行，含急救、部署、lint、WIP）。
- 不把 emoji 语义做成标题自检。

## Decisions

### Decision: 短表加四行，杂项从 wrench 上拿掉

失败点是判断门，不只是缺行。`:sparkles:`「新功能」和 `:wrench:`「配置或杂项」能接住界面、格式、安全和依赖，完整表就永远不会被打开。补上 `:lipstick:`、`:art:`、`:lock:`、`:heavy_plus_sign:`，同时把 `:wrench:` 改回「配置」（与完整表一致）。短表不再提供兜底格。

`:heavy_plus_sign:` 单独占「添加依赖」。升级、降级、移除、锁版本留在完整表的依赖管理，和「添加」写在同一句触发里，避免只补了加号、降级仍掉进 `:wrench:`。

Alternatives considered:

- 只加四行、`:wrench:` 仍写「或杂项」：杂项继续接住没点名的类型，读取门还是不开。
- 短表只写「依赖变更 → 读完整表」、不加 `:heavy_plus_sign:`：添加依赖是短表能说清的一种，不必每次都打开全文。
- 把依赖六种都放进短表：短表开始变成目录，和「默认不展开完整表」对着干。

### Decision: art 与 lipstick 用一句话分开

`:art:` 是代码结构或格式，`:lipstick:` 是界面和样式。只并列 shortcode 时，格式化会被写成口红，样式会被写成画板。表下各写一句主语即可，不另开文档。

只改文案走完整表的 `:speech_balloon:`。界面改动同时改到文案仍用 `:lipstick:`，对应实测那条导航与文案提交。

Alternatives considered:

- 文案一律 `:lipstick:`：纯文案没有样式时，完整表已有更准的类型。
- 文案一律打开完整表、连界面带文案也禁止 `:lipstick:`：和实测提交相反。

### Decision: 读取条件写成场合，不写「不够才读」

`SKILL.md` 的 reference 表和 `cz-emoji-types.md` 开头改成同一句：依赖升级、降级、移除或锁版本，只改文案，CI，国际化。短表里已经有行的语义不再要求打开全文。

`cz-emoji-types.md` 正文目录不动。它开头的「常用类型」和 `commit-convention.md` 的短表职责不同，本次不对齐。

Alternatives considered:

- 保留「不足以覆盖当前语义」再加场合：那句正是被放宽的 `:wrench:` 吃掉的判断，留着等于没改触发。
- 把完整表抄进 `SKILL.md`：违反按需引用。

### Decision: 选词留在 convention，SKILL 不展开类型行

与 scope 选词同一摆法。`commit-convention.md` 是消息真源。`SKILL.md` 最小硬结果仍只保留标题骨架；reference 表只更新何时去读。emoji 对不对靠生成规则和预览里的「为何这个 emoji」，不进 `git log` 自检。

## Risks / Trade-offs

- [Risk] Docker、回滚、lint 等未点名类型仍可能被塞进 `:bug:` 或 `:recycle:`。  
  Mitigation: 短表已无「杂项」。这些不在本次必须点名的场合里；若实测再偏，另开 change 加触发，不把目录搬进短表。

- [Risk] 纯文案和「界面带文案」边界靠判断。  
  Mitigation: 没有样式或界面文件时用 `:speech_balloon:`；有界面或样式则 `:lipstick:`。预览解释必须写为何这个 emoji。

- [Trade-off] 自检不验 emoji 语义，漏看选词仍能提交。  
  Mitigation: 与 scope 选词相同，硬门只验标题骨架。

## Migration Plan

1. 扩写 `commit-convention.md` 常用类型表与表下选词。
2. 改 `SKILL.md` reference 表的读取时机，并改 `cz-emoji-types.md` 开头同一句。
3. CHANGELOG 记录短表与读取条件。
4. 回滚即还原上述 markdown。
