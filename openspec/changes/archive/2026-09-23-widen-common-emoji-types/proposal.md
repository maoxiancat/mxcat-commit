## Why

常用类型短表只有 9 行，`:sparkles:` 写成「新功能」、`:wrench:` 写成「配置或杂项」。界面、代码格式、安全修复和添加依赖都能硬套进这两格，于是「常用类型不够才读完整表」几乎不会触发。实测里界面与文案提交需要 `:lipstick:`，短表却没有这一格。

## What Changes

- 短表补上 `:lipstick:`（界面和样式）、`:art:`（代码结构或格式）、`:lock:`（安全修复）、`:heavy_plus_sign:`（添加依赖）。`:wrench:` 收成「配置」。
- 选词写在短表旁：界面用 `:lipstick:`，代码格式用 `:art:`，安全修复用 `:lock:`，新依赖用 `:heavy_plus_sign:`。依赖升级或移除、只改文案、CI、国际化必须打开完整类型表再选。
- `SKILL.md` 里完整表的读取时机改成上述具体场合。完整类型目录不改，也不展开进主文档。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `mxcat-commit-message-convention`: 常用类型必须覆盖界面、代码格式、安全与添加依赖；`:wrench:` 只表示配置；指定场合必须改用完整表里的类型。
- `mxcat-commit-workflow`: 读取完整 emoji 类型表的条件从「常用类型不足以覆盖」改为上述具体场合；默认加载层仍不预先展开完整表。

## Impact

- 修改 `references/commit-convention.md` 的常用类型表，并在表下写选词与必须打开完整表的场合。
- 修改 `SKILL.md` reference 表中 `cz-emoji-types.md` 的读取时机。
- 修改 `references/cz-emoji-types.md` 开头的读取条件，与新触发对齐；表内类型目录不动。
- `skills/mxcat-commit/CHANGELOG.md` 记录该约束。
- 不新增脚本或测试套件。不改预览门禁、scope 选词或提交命令。
