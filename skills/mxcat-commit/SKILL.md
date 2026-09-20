---
name: mxcat-commit
description: |
  自动分析 git staged 变更，或将整个未提交工作树拆分为多条使用 cz-emoji shortcode 风格的 commit。
  当用户要求：mxcat-commit, commit code, generate commit message, auto commit, 帮我提交, 自动提交, 生成 commit, write commit message, 代码提交, 提交代码, split commits, batch commit，或表达“看看 git 里没提交的代码并分类后分批提交”时使用此技能。
---

# mxcat-commit

## 安装

项目级：

```bash
npx -y skills add maoxiancat/mxcat-commit --skill mxcat-commit
```

全局：

```bash
npx -y skills add maoxiancat/mxcat-commit --skill mxcat-commit -g
```

仅安装到 Cursor 和 Claude Code：

```bash
npx -y skills add maoxiancat/mxcat-commit --skill mxcat-commit -a cursor -a claude-code
```

验证发现见仓库根 `README.md`。

## 默认路由

先看完整工作区：

```bash
git status --short
```

默认走 **Batch commit**（按逻辑分批）。

- **Batch commit**（默认）：按逻辑拆分当前未提交变更。输入默认是整棵工作树（staged + unstaged + untracked）。用户要求 `split commits` / `batch commit` / 「按逻辑分批提交」时也走这条。即使工作区只剩 staged，只要用户没说「合为一个 commit」，仍默认分批。
- **Single commit**：仅当用户明确要求「合为一个 commit」（或「合成一条」「不要拆」「就提交一条」）。把当前输入范围打成 **一条** commit。输入默认仍是整棵工作树；若用户同时要求「只提交暂存区」，则只用 staged。

判定之后再读对应 guide；未判定前不要展开执行细节。

## 预览门禁

single 与 batch 都先出示预览，等人确认，再提交。确认按**本轮对话里是否已完整输出**预览卡 + 固定收尾来判定，不要靠与阶段无关的词表，也不要因为句子里出现「提交」或「push」就执行。

- 确认前禁止运行 `git commit`（含 `--file`、`-m`、会创建提交对象的 amend）与 `git push`。该次回复只批准提交、未要求 push 时，不要运行 `git push`。提交成功后用户再说「帮我 push」「推一下」或 `git push`，可以对当前上游再推一次（不要 `--force`，没有上游不要擅自 `-u`）。
- **尚未出示预览**（含用户**第一句**就说）：「提交」「帮我提交」「提交并 push」「提交并push」「commit and push」「自动提交」「commit」「split commits」等——一律只分析变更、出示预览与固定收尾，**不等于**确认，**禁止**同轮 `git commit` / `git push`。收尾里举例的「提交并 push」是**预览之后**才有效的确认语，不能反向当成首轮可跳过预览的口令。
- **已经出示预览**（同一轮或上一轮已输出完整预览 + 固定收尾）：「提交」「确认提交」「帮我提交」视为批准 commit（不要因此 push）；「提交并 push」视为批准 commit，且全部预定 commit 成功后再 `git push` 一次。不要把单独的「确认」「可以提交」「lgtm」「就这样」当成确认。
- 用户改标题、emoji、scope、正文，或拆分/合并批次，或不要提交某一条时，更新预览并再次等待，同一次回复里不要提交。丢掉的那条对应文件留在工作区，不要对这些文件运行 `git restore` / `checkout` / `reset`。没有剩余条目则停止并说明。
- 仅当用户强调不需要预览（「不需要预览」「跳过预览」「不要预览」）时，才允许跳过预览卡。只说「直接提交」、只给完整标题、或启动语里带「提交」，仍须预览。
- 「合为一条」是改走 single 并重出预览，不是跳过预览。

预览卡至少包含：拟用标题、拟用正文（若有）、以及解释。每条预览用 `## commit N` 起头；编号是身份，丢掉后不滑动，不要写成 `待确认 · 1/N`。解释必须覆盖：为何选该 emoji、为何选该 scope、**改动了哪些部分**。点到模块/文件/行为即可，不要逐行复述 diff。

全部预览条目之后必须另起一段，**原样**输出下面这句（不得改字、换序或增删分句；不要写进某条的解释里）：

尚未提交 commit 和 push，请回复「提交」「提交并 push」等进行提交、push，也可以合并 commit 或不要提交某个 commit

提交或 push 成功后，按对应 guide 的回执样例汇报，不要临场改结构。同一组字段（`Commit：` / `标题：` / `变更：`，或 `分支：` / `仓库地址：`）中间不要空行，除最后一项外行末写 `<br>`；不要写 `远程：`。

## 默认结果约束

完整标题、语言、footer 禁令与示例以 [commit-convention.md](references/commit-convention.md) 为准。主文档只保留最小硬结果：

### Header

- 允许的标题骨架：
  - `:emoji: (scope) subject`
  - `:emoji: (scope) ! subject`
- Header 中的 emoji 必须使用 shortcode，例如 `:bug:`，不要使用 Unicode emoji。
- `scope` **必写**，必须写成 `(scope)`。
- `!` 是独立的 breaking marker，位于 `(scope)` 之后、subject 之前。
- 默认语言只影响 subject 的描述，不改变 header 骨架。

### Body

- Body 保持 bullet 风格，并尽量简洁。
- Header 和正文之间必须保留一个空行。
- 若存在 footer，正文和 footer 之间必须保留一个空行。
- 未声明时 subject 与 body 使用简体中文；用户本轮明确要求英文时再覆盖。

### Footer

- 禁止输出 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:`、`Jira-Refs:`。
- 若存在 `BREAKING CHANGE:`，字段名保持英文；其后的描述文本遵循当前语言（默认中文）。

## 何时读取哪份 Reference

| Reference | 何时读取 | 主要内容 |
|---|---|---|
| [single-commit.md](references/single-commit.md) | 已确定当前是 single commit 时 | staged 分析、预览卡、确认后提交、自检、成功回执 |
| [batch-commit.md](references/batch-commit.md) | 已确定当前是 batch commit 时 | 分组、整单预览、按序提交、中途失败、成功回执 |
| [commit-convention.md](references/commit-convention.md) | 需要 canonical 规范时 | header、必写 scope、语言、footer 禁令、完整示例 |
| [cz-emoji-types.md](references/cz-emoji-types.md) | 常用类型不足以覆盖当前语义时 | 完整 emoji 类型表 |
| [troubleshooting.md](references/troubleshooting.md) | 遇到异常或恢复场景时 | 自检失败、hook、空行、push 无上游、丢掉预览后无剩余项 |
