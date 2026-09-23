## 1. 空行自检命令

- [x] 1.1 改 `references/single-commit.md` 第 6 步「检查空行」：删掉 `git cat-file` + `cat -vet`，换成 design.md 中带 `else` 的 `if`（`%B` 去掉第一行后有非空行才查 `%b`，打印 `OK` / `FAIL`）。不要收成 `&& … || echo FAIL`。batch 已写「做与 single 相同的自检」，不必再写一份

## 2. 故障说明

- [x] 2.1 在 `references/troubleshooting.md`「自检失败：空行丢失」补一句：自检打印 `FAIL` 时按本节处理。不要新开一节，不要改生成规则

## 3. Changelog

- [x] 3.1 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`：记录空行自检改为可判定（有第二段时要求 `%b` 非空）；不改写已发布版本条目正文
