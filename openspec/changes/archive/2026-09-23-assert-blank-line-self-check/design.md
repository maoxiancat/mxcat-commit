## Context

技能仍是文档约束 agent。提交后自检写在 `references/single-commit.md` 第 6 步；batch 已写「做与 single 相同的自检」。见 `proposal.md` 的 Why。不引入执行器仍是既有非目标；本次只把空行检查从目视改成可判定命令。

## Goals / Non-Goals

**Goals:**

- 用 git 自己的 `%B` / `%b` 判定「有第二段内容时，标题后必须有分隔空行」。
- 命令打印 `OK` / `FAIL`，与禁页脚检查同一套可判定输出。
- `SKILL.md` 与 `commit-convention.md` 不展开命令、不改生成规则。

**Non-Goals:**

- 不把「恰好一个空行」写成自检失败（两个空行仍通过）。
- 不验 body 与 `BREAKING CHANGE:` 之间的空行，也不验 bullet 之间的多余空行。
- 不从授权名单拿掉 `git cat-file`。
- 不新增脚本或测试套件。

## Decisions

### Decision: 有第二段非空行时才要求 `%b` 非空

`%b` 为空有两种相反含义：只有标题，或有正文但缺分隔空行。先看 `%B` 去掉第一行后是否还有非空行；没有则 OK；有则 `%b` 必须非空，否则 FAIL。

生成规则仍可以说「恰好一个空行」。自检只兑现 git 能解析出 body 这一档，两个空行不失败。

Alternatives considered:

- 只要求 `%b` 非空：只有标题会被误判失败，与 body 可选冲突。
- awk 数「恰好一个空行」：能拦两个空行，但要处理 `tformat` 尾换行，和现有 `grep` 自检不像。

### Decision: 命令写成带 `else` 的 `if`，贴在 single 第 6 步

```bash
if git log -1 --pretty=%B | tail -n +2 | grep -q .; then
  git log -1 --pretty=%b | grep -q . && echo OK || echo FAIL
else
  echo OK
fi
```

仍用 `pretty=%B` / `%b`（与 header、禁页脚同一写法）。`grep -q .` 不匹配空行，tformat 多出来的尾换行不会把「只有标题」当成有第二段。

禁止收成 `A && B && echo OK || echo FAIL`：只有标题时第一段为假，最后的 `|| echo FAIL` 仍会跑。

换掉 `git cat-file -p HEAD | sed … | cat -vet`。batch 不另写一份。

Alternatives considered:

- `pretty=format:%B`：A2 不需要；改了反而不和同一步其它检查一致。
- 把命令收成禁页脚那种一行：见上，会回到 naive `%b` 非空。

### Decision: 规格写在 convention，命令写在 single，SKILL 不展开

`mxcat-commit-message-convention` 补自检门。`commit-convention.md` 继续只写生成结果。troubleshooting「空行丢失」补一句按 FAIL 处理。CHANGELOG 用 changelog-content-writer 记一笔。

## Risks / Trade-offs

- [Risk] Agent 把 `if` 收成一行 `&& ||`，只有标题误判 FAIL。  
  Mitigation: guide 写明必须带 `else`；不要抄禁页脚那行的结构。

- [Risk] 两个空行或 footer 粘住仍通过。  
  Mitigation: 接受；缺分隔空行才是这张票的故障。升级「恰好」或 footer 属于另一次 change。

- [Trade-off] 文档约束挡不住 Agent 跳过整段自检。  
  Mitigation: 与既有 header / 禁页脚同一层次；本次不引入脚本。

## Migration Plan

1. 改 `single-commit.md` 第 6 步空行检查为上面的 `if`。
2. troubleshooting「空行丢失」补 FAIL 处理。
3. CHANGELOG 记录该自检。
4. 回滚即还原上述 markdown。
