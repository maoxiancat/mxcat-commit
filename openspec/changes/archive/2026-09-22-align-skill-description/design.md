## Context

见 `proposal.md` 的 Why。技能仍是文档约束 agent：`description` 是目录层（加载前），正文才是路由器。本次只改 frontmatter 的 WHAT 与一处引用表用词；不改 workflow 分流、预览门禁或提交命令。

## Goals / Non-Goals

**Goals:**

- 让目录层第一句与正文默认路由同一套故事，避免 agent 只跑 `git diff --cached`。
- 触发短语列表保持可发现，不为了和其它 commit 技能区分而改 WHEN。

**Non-Goals:**

- 不改 single / batch 执行步骤、确认词、`--only`、密钥分类。
- 不在 `description` 里展开确认词表、提交命令或密钥名单。
- 不把 workflow spec 的分流规则再写一遍；路由已经正确。

## Decisions

### Decision: 只改 WHAT，WHEN 原样保留

`description` 分两段：第一段写做什么（整棵工作树、先预览再分批、合为一条才走 single、cz-emoji + 必写 scope + 默认中文）；第二段保持现有触发词，含 `mxcat-commit`。不增、不删触发短语。

预览 / 必写 scope / 默认中文留在 WHAT，因为那是产品事实，会改变 agent 对「加载后该怎么做」的预期。它们不是为了抢触发词。

拟用文案：

```yaml
description: |
  分析整棵未提交工作树（staged、unstaged、untracked），先出示预览再按逻辑分批提交；仅当用户明确要求合为一条（或不要拆、就提交一条）时走 single。标题用 cz-emoji shortcode 且必写 (scope)，subject 默认简体中文。
  当用户要求：mxcat-commit, commit code, generate commit message, auto commit, 帮我提交, 自动提交, 生成 commit, write commit message, 代码提交, 提交代码, split commits, batch commit，或表达“看看 git 里没提交的代码并分类后分批提交”时使用此技能。
```

Alternatives considered:

- 只改第一句、不写预览/scope/中文：目录层仍可能把本技能当成「看完 staged 直接 commit」。
- 为差异化追加触发词：用户已明确不在乎和其它技能抢词；包装 spec 也不要求区分。
- 把确认词表或 `--only` 写进 description：超过目录层职责，也挤占 1024 字符上限。

### Decision: 引用表「staged 分析」随手改掉，不升格为 workflow 需求

`SKILL.md` 引用表把 `single-commit.md` 摘要写成「staged 分析」。single 的默认输入已是整棵工作树。改成「分析变更、预览卡、确认后提交、自检、成功回执」即可。不为此改 `mxcat-commit-workflow`：那是正文用词，不是分流行为变化。

Alternatives considered:

- 给 workflow 加一条「引用表不得写 staged」：过度规格化一句表格。

## Risks / Trade-offs

- [Risk] 目录层 agent 仍可能忽略新 WHAT，继续只看 staged。  
  Mitigation: 第一句正面写「整棵未提交工作树」，并禁止 staged 主输入；加载正文后路由层会再纠正。无法从文档层保证发现算法。

- [Trade-off] 与其它 commit 技能的触发词仍然重叠。  
  Mitigation: 接受。本次不为抢词改 WHEN。

## Migration Plan

1. 按上面拟用文案替换 `SKILL.md` frontmatter `description`。
2. 改引用表 single 那行摘要。
3. CHANGELOG 记该对齐；不改写已发布版本条目正文。
4. 回滚即还原 `SKILL.md` 与 CHANGELOG。
