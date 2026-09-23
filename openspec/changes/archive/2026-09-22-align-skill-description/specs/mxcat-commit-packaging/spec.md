## ADDED Requirements

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
