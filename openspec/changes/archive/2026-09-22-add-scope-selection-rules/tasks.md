## 1. 选词真源

- [x] 1.1 改 `references/commit-convention.md` Header：把「模块、目录或功能面，短词，不要空格」换成硬门（括号内无空白、只一个 `(scope)`、禁止并列）和选词（一个小写英文短词、连字符仅保留源名已有的、按主语在产品面/共享层/工具链中选、不拼路径、不写名单；skill 快照用 `skills`，单 skill 用包名；无主面则拆批，不用 misc/all/update/wip）
- [x] 1.2 在同一文档错误示例中补 `(my scope)`、`(auth,api)`、`(misc)` 一类反例，并写明它们不合规的原因；保留现有 `(charts)` 正例，不要把 `home|vote|styles` 写成词表

## 2. 自检与故障说明

- [x] 2.1 改 `references/single-commit.md` 第 6 步标题自检：把 `\([^)]+\)` 收成 `\([^)\s]+\)`；不要收成 kebab 字符集。batch 已写「做与 single 相同的自检」，不必再写一份正则
- [x] 2.2 在 `references/troubleshooting.md`「自检失败：标题不合规」补一句：括号内空白也算失败

## 3. Changelog

- [x] 3.1 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`：记录 scope 选词规则与括号内禁空格自检；不改写已发布版本条目正文
