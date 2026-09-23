# mxcat-commit-packaging Specification

## Purpose

定义 `mxcat-commit` 技能包如何被目录发现、如何声明身份与触发词，以及如何通过 GitHub 上的公开 `npx skills` 安装到多种 Agent。

## Requirements

### Requirement: 技能包路径与身份 SHALL 可被 skills CLI 发现
仓库 SHALL 在 `skills/mxcat-commit/SKILL.md` 提供技能入口。该文件的 YAML frontmatter `name` MUST 为 `mxcat-commit`。`description` MUST 包含本技能的提交触发短语，并包含技能名 `mxcat-commit`。

#### Scenario: CLI 列出仓库中的技能
- **WHEN** 对仓库根执行 `npx skills add <source> --list`（或等价 list 能力）
- **THEN** 输出中 MUST 出现名为 `mxcat-commit` 的技能

#### Scenario: frontmatter 身份
- **WHEN** 读取 `skills/mxcat-commit/SKILL.md` 的 YAML frontmatter
- **THEN** `name` MUST 等于 `mxcat-commit`
- **AND** `description` MUST 包含触发短语，例如 `帮我提交`、`auto commit`、`split commits`、`batch commit`
- **AND** 文档 MUST NOT 设置 `disable-model-invocation: true`

### Requirement: 安装文案 SHALL 使用公开 skills CLI
技能包与仓库 README MUST 提供可用 `npx -y skills add` 安装本技能的命令，覆盖项目级安装、全局 `-g` 安装，以及通过 `-a` 仅安装到指定 Agent（至少包含 Cursor 与 Claude Code）。全局安装与指定 Agent 是两件独立的事，文档 MUST 分开写，不得合成一条命令。GitHub owner 已确定为 `maoxiancat`。

#### Scenario: 项目级安装命令存在
- **WHEN** 用户阅读仓库 README 或技能 `SKILL.md` 的安装章节
- **THEN** 文档 MUST 给出项目级命令，形如 `npx -y skills add <owner>/mxcat-commit --skill mxcat-commit`
- **AND** MUST 单独给出全局示例，形如带 `-g`、不带 `-a`
- **AND** MUST 单独给出仅安装到指定 Agent 的示例，包含 `-a cursor`、`-a claude-code`，不带 `-g`

### Requirement: 托管源 SHALL 是 GitHub
对外发布的 git 源 MUST 是 GitHub 仓库。他人 MUST 能用 GitHub shorthand `owner/mxcat-commit` 或对应 git URL 作为 `npx skills add` 的源。

#### Scenario: 使用 GitHub shorthand 安装
- **WHEN** GitHub 远程已存在且仓库包含 `skills/mxcat-commit/SKILL.md`
- **THEN** `npx skills add <owner>/mxcat-commit --skill mxcat-commit` MUST 能发现并安装该技能

### Requirement: frontmatter description SHALL 与默认路由一致
`SKILL.md` 的 YAML `description` MUST 描述本技能的真实默认行为：默认输入为整棵未提交工作树（staged、unstaged、untracked）；默认先出示预览再按逻辑分批提交；仅当用户明确要求合为一条 commit 时走 single。该字段 MUST 点到 cz-emoji shortcode、必写 `(scope)`、以及 subject 默认简体中文。该字段 MUST NOT 把 staged 写成主输入，MUST NOT 用「分析 staged 变更，或将整个未提交工作树拆分」这类并列把 staged 放在整棵工作树之前。该字段 MUST NOT 展开确认词表、提交命令或密钥名单。既有提交触发短语与技能名 `mxcat-commit` MUST 仍出现在 `description` 中。

#### Scenario: description 写明整棵工作树与默认分批
- **WHEN** 读取 `skills/mxcat-commit/SKILL.md` 的 YAML `description`
- **THEN** 该字段 MUST 说明默认分析整棵未提交工作树
- **AND** MUST 说明先出示预览再按逻辑分批提交
- **AND** MUST 说明仅当用户明确要求合为一条 commit 时走 single
- **AND** MUST 点到 cz-emoji shortcode、必写 `(scope)`、以及 subject 默认简体中文

#### Scenario: description 不得把 staged 写成主输入
- **WHEN** 读取 `skills/mxcat-commit/SKILL.md` 的 YAML `description`
- **THEN** 该字段 MUST NOT 以「分析 git staged 变更」或同等说法作为默认输入
- **AND** MUST NOT 用「分析 staged，或拆工作树」这类并列把 staged 写在整棵工作树之前

#### Scenario: 既有触发短语仍在
- **WHEN** 读取 `skills/mxcat-commit/SKILL.md` 的 YAML `description`
- **THEN** 该字段 MUST 包含技能名 `mxcat-commit`
- **AND** MUST 包含既有提交触发短语，包括 `帮我提交`、`auto commit`、`split commits`、`batch commit`

### Requirement: 技能目录 SHALL 带上提交入口脚本
技能包 MUST 在 `skills/mxcat-commit/scripts/` 提供 `validate`、`commit_one`、`validate.ps1` 与 `commit_one.ps1`。`validate` 与 `commit_one` MUST 可执行。经 `npx skills` 安装得到的 `mxcat-commit` 技能目录 MUST 仍包含这四个路径。

#### Scenario: 源目录包含两个环境的入口
- **WHEN** 查看仓库中的 `skills/mxcat-commit/scripts/`
- **THEN** MUST 存在 `validate`、`commit_one`、`validate.ps1` 与 `commit_one.ps1`
- **AND** `validate` 与 `commit_one` MUST 可执行

#### Scenario: 安装结果仍包含入口
- **WHEN** 用 `npx skills` 安装 `mxcat-commit` 后查看该技能目录
- **THEN** 该目录下 MUST 仍有 `scripts/validate`、`scripts/commit_one`、`scripts/validate.ps1` 与 `scripts/commit_one.ps1`
