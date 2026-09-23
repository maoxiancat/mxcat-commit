## 1. 短表与选词

- [x] 1.1 改 `references/commit-convention.md` 常用类型：补上 `:lipstick:`（界面和样式）、`:art:`（代码结构或格式）、`:lock:`（安全修复）、`:heavy_plus_sign:`（添加依赖）；把 `:wrench:` 从「配置或杂项」收成「配置」。保留原有 `:sparkles:`、`:bug:`、`:memo:`、`:recycle:`、`:zap:`、`:white_check_mark:`、`:truck:`、`:fire:`
- [x] 1.2 在同一张表下写选词：界面或样式用 `:lipstick:`，代码格式用 `:art:`，安全修复用 `:lock:`（普通缺陷仍用 `:bug:`），添加依赖用 `:heavy_plus_sign:`，配置用 `:wrench:`。依赖升级、降级、移除或锁版本，只改文案，以及 CI、国际化，必须打开 `cz-emoji-types.md` 再选；只改文案用其中的 `:speech_balloon:`；界面同时改到文案仍用 `:lipstick:`。不要把这些类型再加进短表，也不要把 emoji 语义写进标题自检

## 2. 读取时机

- [x] 2.1 改 `SKILL.md` reference 表里 `cz-emoji-types.md` 的读取时机：写成依赖升级、降级、移除或锁版本，只改文案，CI，国际化。不要保留「常用类型不足以覆盖当前语义」。不要把完整类型表展开进 `SKILL.md`
- [x] 2.2 改 `references/cz-emoji-types.md` 开头的读取条件，与 2.1 同一句。表内类型目录和它自己的「常用类型」一节不动

## 3. Changelog

- [x] 3.1 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`：记录短表补上界面、格式、安全与添加依赖，以及 `:wrench:` 只表示配置、指定场合才读完整表。不改写已发布版本条目正文
