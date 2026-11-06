# mxcat-commit Specification

## Purpose

定义公开技能 `mxcat-commit` 的现行行为。本规格从 `skills/mxcat-commit/` 的入口、安装说明与 `references/` 反向整理：分析整棵未提交工作树，先出示预览，确认后再按语义分批提交，并在用户要求时推送。技能包不附带提交脚本；创建、撤回与推送都由 Agent 按本规格调用 git 完成。

## Requirements

### Requirement: 技能入口 SHALL 声明身份并指向全部规范
仓库 SHALL 在 `skills/mxcat-commit/SKILL.md` 提供技能入口。YAML `name` MUST 为 `mxcat-commit`。`description` MUST 说明该技能用于辅助提交 commit，默认分析整棵未提交工作树，先出示预览再按逻辑分批提交，并为代码提交、生成 commit message、自动提交和分批提交提供规范，覆盖预览确认、commit 标题、commit 内容与 push。安装与验证 MUST 指向同目录 `README.md`。入口 MUST 列出并要求读取下列规范：流程、commit 标题、commit 内容、commit 分批、预览、成功回应、commit 提交/push、安全提醒、异常恢复。

#### Scenario: 读取技能入口
- **WHEN** 读取 `skills/mxcat-commit/SKILL.md`
- **THEN** `name` MUST 等于 `mxcat-commit`
- **AND** `description` MUST 写明整棵未提交工作树、先预览再按逻辑分批提交，以及预览、标题、内容与 push 规范
- **AND** 规范表 MUST 指向 `references/` 下的 `workflow.md`、`commit-header.md`、`commit-body.md`、`batch-commit.md`、`preview.md`、`success-response.md`、`commit-push.md`、`security-reminder.md`、`recovery.md`

### Requirement: 冲突时 SHALL 以用户和仓库规则为准
用户或目标仓库另有规则且与本技能冲突时，技能 MUST 以用户和仓库一侧为准。

#### Scenario: 仓库规则与技能冲突
- **WHEN** 目标仓库的提交规则与本技能的标题或流程要求冲突
- **THEN** 技能 MUST 采用用户和仓库一侧的规则

### Requirement: 安装说明 SHALL 给出公开安装与列出命令
仓库根 `README.md` 与 `skills/mxcat-commit/README.md` MUST 把源仓库写为 `https://github.com/maoxiancat/mxcat-commit`，并分别给出项目级安装、全局安装，以及只安装到 Cursor 与 Claude Code 的命令。技能目录 README MUST 说明技能包入口是同目录的 `SKILL.md`，并说明列出源技能时输出中应出现 `mxcat-commit`。仓库根 README MUST 同时给出用本地路径列出技能的命令。

#### Scenario: 阅读两份 README 的安装命令
- **WHEN** 读取仓库根 `README.md` 或 `skills/mxcat-commit/README.md` 的安装章节
- **THEN** 文档 MUST 包含 `npx -y skills add maoxiancat/mxcat-commit --skill mxcat-commit`
- **AND** MUST 包含带 `-g` 的全局安装命令
- **AND** MUST 包含 `-a cursor -a claude-code` 的指定 Agent 安装命令
- **AND** 全局安装与指定 Agent MUST 分成两条命令

#### Scenario: 验证技能可被列出
- **WHEN** 读取仓库根 README 的验证章节
- **THEN** 文档 MUST 包含 `npx -y skills add maoxiancat/mxcat-commit --list`
- **AND** MUST 包含以本地仓库路径执行 `npx -y skills add <path> --list` 的示例
- **AND** 技能目录 README MUST 要求该列出结果中出现 `mxcat-commit`

### Requirement: 技能包 SHALL NOT 附带提交脚本
技能目录 MUST NOT 提供 `scripts/validate`、`scripts/commit_one`、`scripts/validate.ps1` 或 `scripts/commit_one.ps1`。提交、按 hunk 写入与推送 MUST 由 Agent 按提交流程直接调用 git。

#### Scenario: 查看技能目录
- **WHEN** 查看 `skills/mxcat-commit/`
- **THEN** 该目录 MUST NOT 包含上述四个脚本路径

### Requirement: 输入范围 SHALL 默认覆盖整棵未提交工作树
技能 MUST 先用 `git status --short` 了解工作区。默认输入 MUST 为整棵未提交工作树，包含 staged、unstaged 与 untracked。用户明确要求只提交某部分时，预览和提交 MUST 只覆盖该部分。输入范围内没有任何变更时，技能 MUST 停止并说明，且 MUST NOT 擅自 `git add`。

#### Scenario: 用户只要求提交
- **WHEN** 用户要求提交且未把范围收窄到某一部分
- **THEN** 技能 MUST 分析 staged、unstaged 与 untracked
- **AND** 预览 MUST 覆盖这整棵未提交工作树中要提交的变更

#### Scenario: 用户只要其中一部分
- **WHEN** 用户明确要求只提交工作树中的某一部分
- **THEN** 预览 MUST 只出示该部分
- **AND** 随后的 commit MUST 只提交该部分

#### Scenario: 范围内没有变更
- **WHEN** 输入范围内没有任何变更
- **THEN** 技能 MUST 停止并说明
- **AND** MUST NOT 运行 `git add`

### Requirement: 分析与预览阶段 SHALL 保持只读并按序进行
了解概况并确认输入范围之后，出预览之前的分析 MUST 只使用只读 git 命令，例如 `git status`、`git diff`、`git log`、`git show`。该阶段 MUST NOT 修改 index、HEAD 或工作区。分析时 MUST 按分批规范分组，并按标题规范与内容规范起草每条消息。出示预览、等待确认或改稿、确认后提交或推送、成功回应、异常恢复 MUST 按流程规范的顺序进行。给出预览的同时 MUST NOT 提交或 push。

#### Scenario: 尚未确认就分析工作树
- **WHEN** 技能正在分组并起草预览
- **THEN** 它 MUST 只运行不改 index、HEAD 与工作区的 git 命令
- **AND** MUST NOT 在同一轮里创建 commit 或 push

### Requirement: commit 标题 SHALL 使用一种类型体系与固定骨架
未声明语言时，subject MUST 使用简体中文。本轮明确要求英文或其他语言时，subject MUST 改用该语言。语言要求 MUST NOT 改变 type 或 scope。允许的标题骨架 MUST 只有以下两种：

```text
:type: (scope) subject
:type: (scope) ! subject
```

type MUST 要么全程使用 shortcode，要么全程使用 Conventional Commits 文字类型，两套 MUST NOT 混用。选用哪一套 MUST 跟随该仓库已有 commit；已有 commit 两种都不是时 MUST 使用 shortcode。写出的 type MUST 包在一对冒号里，文字类型也写成 `:feat:` 这种形式。允许的类型标识与使用场景见 shortcode 与文字类型两条要求。

`(scope)` MUST 保留括号。括号内 MUST 是单段小写名称，只含小写字母、数字与连字符，MUST NOT 含空格、制表符、大写字母、下划线或逗号，MUST NOT 写成 `(auth,api)`。`!` MUST 是独立的 breaking 标记，位于 `(scope)` 之后、subject 之前，两侧各一个空格，且 MUST 使用半角感叹号。

#### Scenario: 仓库历史使用 shortcode
- **WHEN** 仓库已有 commit 使用 shortcode，且本轮未要求改语言
- **THEN** 新标题的 type MUST 使用上述 shortcode 之一
- **AND** subject MUST 为简体中文
- **AND** scope MUST 匹配单段小写名称

#### Scenario: 仓库历史使用文字类型
- **WHEN** 仓库已有 commit 使用 Conventional Commits 文字类型
- **THEN** 新标题 MUST 写成 `:feat:` 这类冒号包裹形式
- **AND** MUST NOT 在同一标题中混入 shortcode

#### Scenario: 历史两种类型都不是
- **WHEN** 仓库已有 commit 既不是 shortcode 也不是文字类型
- **THEN** 新标题 MUST 使用 shortcode

#### Scenario: 本轮要求英文
- **WHEN** 用户在本轮明确要求 subject 使用英文
- **THEN** subject MUST 使用英文
- **AND** type 与 scope MUST 仍按类型表和 scope 规则书写

#### Scenario: 破坏性变更
- **WHEN** 该提交是破坏性变更
- **THEN** 标题 MUST 在 `(scope)` 与 subject 之间放入两侧带空格的半角 `!`

### Requirement: shortcode SHALL 使用 emoji 类型表
选用 shortcode 时，type MUST 来自 `references/modify-type-list/emoji-shortcode-list.md`。闭集 MUST 为 `:sparkles:`、`:bug:`、`:boom:`、`:memo:`、`:art:`、`:recycle:`、`:zap:`、`:white_check_mark:`、`:package:`、`:construction_worker:`、`:wrench:`、`:rewind:`、`:lipstick:`、`:fire:`、`:tada:`、`:twisted_rightwards_arrows:`、`:bookmark:`、`:ambulance:`、`:construction:`、`:label:`、`:see_no_evil:`、`:card_file_box:`。含义与使用场景 MUST 以该表为准。

#### Scenario: 用 shortcode 表示新增功能
- **WHEN** 本次变更是新增功能，且仓库使用 shortcode
- **THEN** type MUST 为 `:sparkles:`
- **AND** MUST NOT 改用该表之外的 shortcode

### Requirement: 文字类型 SHALL 使用 Conventional Commits 类型表
选用文字类型时，type MUST 来自 `references/modify-type-list/conventional-commits-list.md`。常用类型 MUST 为 `feat`、`fix`、`docs`、`style`、`refactor`、`perf`、`test`、`build`、`ci`、`chore`、`revert`。扩展类型 MUST 为 `init`、`merge`、`release`、`hotfix`、`wip`、`types`。写出时 MUST 包在冒号里。含义与使用场景 MUST 以该表为准。

#### Scenario: 用文字类型表示缺陷修复
- **WHEN** 本次变更是缺陷修复，且仓库使用文字类型
- **THEN** 标题中的 type MUST 为 `:fix:`
- **AND** MUST NOT 改用该表之外的文字类型

### Requirement: commit 正文 SHALL 使用精炼 bullet 并隔开 footer
未声明语言时，body MUST 使用简体中文。本轮明确要求英文或其他语言时，body MUST 改用该语言。语言要求 MUST NOT 改变 type 或 scope。body MUST 保持 bullet，并用精炼语言描述。header 与正文之间 MUST 保留一个空行。存在 footer 时，正文与 footer 之间 MUST 保留一个空行。消息 MUST NOT 包含 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:` 或 `Jira-Refs:`。存在 `BREAKING CHANGE:` 时，字段名 MUST 保持英文，其后的描述 MUST 使用当前 subject 与 body 的语言。

#### Scenario: 普通中文提交
- **WHEN** 技能起草一条没有 footer 的提交，且本轮未要求其他语言
- **THEN** header 与第一条 bullet 之间 MUST 有一个空行
- **AND** body MUST 为简体中文 bullet
- **AND** 消息 MUST NOT 包含上述 AI 署名或 `Jira-Refs:`

#### Scenario: 带破坏性说明
- **WHEN** 消息包含 `BREAKING CHANGE:`
- **THEN** 正文与该 footer 之间 MUST 有一个空行
- **AND** 字段名 MUST 保持 `BREAKING CHANGE:`
- **AND** 冒号后的描述 MUST 与当前 body 语言一致

### Requirement: 分批 SHALL 按语义切分并保持 hunk 完整
技能 MUST 按语义拆分：同一功能、同一意图或同一模块放进同一条 commit，无关改动拆开。每条 commit MUST 语义自洽，并能独立构成一条合法、完整的提交消息。只有一组语义时 MUST 保持一条 commit。同一个已跟踪文件可以出现在多条 commit 中；每条带走的 MUST 是 `git diff HEAD` 里的完整 hunk，各条之间的 hunk MUST NOT 重叠。有先后依赖时，被依赖的改动 MUST 排在前面。暂存与否 MUST NOT 作为拆分依据。用户明确要求把某几类改动合并进同一条时，MUST 按用户的分法。依赖、skill、图片等非业务逻辑的更新、添加或删除，默认 MUST 与业务拆成不同条目；非业务逻辑之间也 MUST 按种类拆开。疑似密钥、凭证或个人信息 MUST NOT 改变拆分，只按安全提醒规范提醒。

#### Scenario: 两类无关改动
- **WHEN** 工作树同时有图表功能改动和与之无关的依赖升级
- **THEN** 技能 MUST 把它们拆成不同 commit
- **AND** 依赖升级 MUST NOT 与业务改动放在同一条

#### Scenario: 只有一组语义
- **WHEN** 输入范围内的变更同属一个功能意图
- **THEN** 预览 MUST 只有一条 commit

#### Scenario: 同一文件的两处改动分属两条语义
- **WHEN** 一个已跟踪文件含两段互不重叠、且分属不同语义的完整 hunk
- **THEN** 两条 commit MUST 可以都包含该文件
- **AND** 每条 MUST 只带走自己的完整 hunk

#### Scenario: 用户指定合并
- **WHEN** 用户明确要求把某几类改动合并进同一条
- **THEN** 技能 MUST 按用户的分法分组

### Requirement: 预览门禁 SHALL 挡住未确认的提交
尚未出示预览时，「提交」「帮我提交」「可以提交」「提交并 push」「commit」「commit and push」等说法 MUST 只触发分析并出示预览。给出预览的同时 MUST NOT 提交或 push。只有用户明确要求跳过预览时，才可以不出示预览并继续提交或 push。预览阶段 MUST 只使用只读 git 命令，MUST NOT 修改 index、HEAD 或工作区。用户对已出示的预览作出陈述语气的确认后，才可以按提交/push 规范继续。更改标题或内容、合并或拆分条目、丢掉条目之后，MUST 重出整单预览并再次等待确认，MUST NOT 直接提交或 push。

#### Scenario: 第一句就是要求提交
- **WHEN** 本轮还没有出示过预览，用户说「帮我提交」或「commit and push」
- **THEN** 技能 MUST 只分析变更并出示预览
- **AND** MUST NOT 创建 commit 或 push

#### Scenario: 用户确认预览
- **WHEN** 预览已经出示，用户用陈述语气确认提交
- **THEN** 技能 MUST 按提交/push 规范继续

#### Scenario: 用户改了其中一条标题
- **WHEN** 用户要求修改已出示预览中的标题、正文、分批或删掉某条
- **THEN** 技能 MUST 输出改稿后的整单预览
- **AND** MUST NOT 在下一次确认前提交或 push

#### Scenario: 用户要求跳过预览
- **WHEN** 用户明确要求跳过预览
- **THEN** 技能可以不出示预览并继续提交或 push

### Requirement: 预览 SHALL 按四段输出并以固定句子收尾
每条拟提交 commit 的预览 MUST 分成序号、标题、正文、解释四部分，部分之间 MUST 保留一个空行。序号 MUST 使用 `## commit N`。标题与正文 MUST 遵守标题规范、内容规范与分批规范。解释 MUST 说明为什么使用该 type、为什么使用该 scope。同一已跟踪文件出现在多条预览时。全部条目之后 MUST 先处理安全提醒块，再空一行，然后原样输出：

```text
尚未提交/push commit，请回复「提交」「提交并 push」等进行提交、push，如要改稿，请直接说明需要做的改动，将重出整单预览
```

#### Scenario: 出示两条语义分开的预览
- **WHEN** 分析定稿为两条 commit，且没有需要提醒的新增敏感内容
- **THEN** 输出 MUST 依次包含 `## commit 1` 与 `## commit 2`
- **AND** 每条 MUST 含标题、正文，以及说明 type 与 scope 的解释
- **AND** MUST NOT 插入提醒块
- **AND** 末尾 MUST 是上述固定收尾

### Requirement: 安全提醒 SHALL 只标记新增敏感内容且不阻断提交
出预览前和提交前，技能 MUST 检查拟提交内容。新增内容里疑似密钥、凭证或个人信息时 MUST 提醒。已有内容里的同类信息 MUST NOT 提醒。提醒 MUST NOT 把该路径排除出拟提交条目，也 MUST NOT 阻止提交或 push。预览中的提醒 MUST 单独成块，位于全部条目之后、固定收尾之前，每条路径一行，且 MUST NOT 写进某条的解释。提醒里 MUST 只写路径，MUST NOT 抄写密钥、凭证或个人信息本身。没有此类路径时 MUST NOT 加提醒块。

#### Scenario: 新的环境文件含疑似密钥
- **WHEN** 拟提交内容新增了从未进入仓库、且看起来含有密钥的 `.env`
- **THEN** 预览 MUST 仍为该文件保留对应条目
- **AND** 全部条目之后、固定收尾之前 MUST 有只含路径的提醒块
- **AND** 提醒块 MUST NOT 抄写密钥内容

#### Scenario: 敏感内容本来就在仓库里
- **WHEN** 拟提交改动碰到的密钥或个人信息属于已有内容
- **THEN** 技能 MUST NOT 为该路径添加提醒块

#### Scenario: 没有敏感新增
- **WHEN** 拟提交内容没有新增的疑似密钥、凭证或个人信息
- **THEN** 预览 MUST NOT 包含提醒块

### Requirement: 确认后 SHALL 按预览提交并在失配时停下来
没有更具体的要求时，技能 MUST 按预览的标题、正文和顺序提交每一条拟提交 commit。用户要求只提交部分条目时，MUST 按原序只提交这些条目，其余文件 MUST 留在工作区，且 MUST NOT `git restore`。同一已跟踪文件出现在多条预览时，每条 commit MUST 只带走预览标明的 hunk。提交前若实际内容与预览不一致，MUST 按新内容重新预览，MUST NOT 提交。提交成功后 MUST 按成功回应规范输出。

#### Scenario: 确认提交全部条目
- **WHEN** 用户确认提交，且没有要求只提交其中一部分，也没有要求 push
- **THEN** 技能 MUST 按预览顺序创建全部条目
- **AND** 每条消息 MUST 与对应预览的标题和正文一致
- **AND** MUST NOT push

#### Scenario: 只提交点名的条目
- **WHEN** 用户要求只提交预览中的部分条目
- **THEN** 技能 MUST 按原序只创建这些条目
- **AND** 未点名条目涉及的文件 MUST 留在工作区
- **AND** MUST NOT 对这些文件执行 `git restore`

#### Scenario: 提交前内容已经对不上预览
- **WHEN** 准备创建某条 commit 时，其内容与该条预览不一致
- **THEN** 技能 MUST 用新内容重新出示预览
- **AND** MUST NOT 创建该 commit

### Requirement: push SHALL 只发生在用户要求且本次提交完成之后
用户只要求提交、未明确要求 push 时，技能 MUST NOT push。需要 push 时，MUST 等拟提交的 commit 全部创建成功后再统一 push 一次。push MUST 只覆盖预览中拟提交的 commit；不属于该预览的 commit MUST NOT 被 push，并 MUST 向用户提醒。没有用户明确要求时 MUST NOT force push。没有上游时 MUST 报告原因并停止，MUST NOT 在用户确认前执行 `git push -u`。远程不止一条分支时，直接 push 到 `main` 或 `master` 之前 MUST 提醒用户，并 MUST 等用户确认后才 push。push 成功后 MUST 按成功回应规范输出。

#### Scenario: 用户只说提交
- **WHEN** 用户确认的是提交，没有要求 push
- **THEN** 技能 MUST NOT push

#### Scenario: 用户要求提交并 push
- **WHEN** 用户要求提交并 push，且每条拟提交 commit 都已创建成功
- **THEN** 技能 MUST 在全部创建完成之后执行一次 push
- **AND** MUST NOT 在每条 commit 之后各 push 一次

#### Scenario: 分支上还有预览之外的提交
- **WHEN** 本地还有不属于本次预览的未推送 commit
- **THEN** 本次 push MUST NOT 推送那些 commit
- **AND** 技能 MUST 提醒用户

#### Scenario: 当前分支没有上游
- **WHEN** 用户要求 push，但当前分支没有上游
- **THEN** 技能 MUST 报告原因并停止
- **AND** MUST NOT 自行执行 `git push -u`

#### Scenario: 远程有多条分支且当前是 main
- **WHEN** 远程不止一条分支，用户要求直接 push 到 `main` 或 `master`
- **THEN** 技能 MUST 先提醒
- **AND** MUST 等用户确认直接 push 到该分支后才 push

### Requirement: 中途失败 SHALL 撤回本次已创建的 commit 并再试一次
按序提交时，任意一条 commit 失败，技能 MUST 停止后续提交和 push，用 `git reset --soft` 撤回本次已经创建且尚未 push 的 commit，MUST NOT `git restore`，然后尝试重新提交。重新提交仍然失败时，MUST 向用户说明，且 MUST NOT 使用成功回应的开头。

#### Scenario: 第二条 commit 创建失败
- **WHEN** 预览有多条，前面的 commit 已创建，下一条 `git commit` 失败
- **THEN** 技能 MUST NOT 继续创建后面的条目
- **AND** MUST NOT push
- **AND** MUST 用 `git reset --soft` 撤回本次已创建的 commit
- **AND** MUST NOT `git restore`
- **AND** MUST 尝试重新提交

#### Scenario: 重试仍然失败
- **WHEN** 撤回后的重新提交再次失败
- **THEN** 技能 MUST 向用户说明
- **AND** MUST NOT 以「已提交完成。」或「已提交并推送完成。」开头

### Requirement: 成功回应 SHALL 只报告本次实际完成的提交
任一条 commit 失败、自检失败、没有上游或 push 失败时，回应 MUST NOT 使用成功开头。成功回应 MUST 只使用只读命令，MUST NOT 修改 index、HEAD 或工作区，并且 MUST 只列出本次实际提交或 push 的 commit。每条 commit 信息 MUST 包含短 hash、完整 header，以及影响文件数和行数。短 hash 与完整 header MUST 来自 `git log --oneline`。行数 MUST 来自 `git show --stat`：只有增加时写成 `+N 行`，只有删除时写成 `-N 行`，同时有增加和删除时写成 `+A / -B 行`。工作区 MUST 用 `git status --short` 判断。分支 MUST 用 `git rev-parse --abbrev-ref HEAD` 取得。仓库名与仓库地址 MUST 用 `git remote get-url origin` 取得；仓库地址 MUST 去掉末尾 `.git`。获取失败时 MUST 省略仓库名或仓库地址那一行。

#### Scenario: 列出本次提交
- **WHEN** 本轮提交成功并输出成功回应
- **THEN** 每条 commit MUST 含有来自 `git log --oneline` 的短 hash 和完整标题
- **AND** 行数 MUST 按 `git show --stat` 写成 `+N 行`、`-N 行` 或 `+A / -B 行`

#### Scenario: 取得远程地址失败
- **WHEN** `git remote get-url origin` 失败
- **THEN** 成功回应 MUST 省略仓库名和仓库地址行

#### Scenario: 提交或推送没有全部成功
- **WHEN** 任一条 commit 失败、自检失败、没有上游或 push 失败
- **THEN** 回应 MUST NOT 以「已提交完成。」「已推送完成。」或「已提交并推送完成。」开头

### Requirement: 只提交成功时 SHALL 使用提交完成回应
本轮只提交且全部成功时，开头 MUST 为「已提交完成。」。工作区为空时，结尾 MUST 为「当前工作区已无未提交变更，若要推送到 仓库名/所处分支，可以说一声我帮你执行 git push。」，其中仓库名与分支使用实际值。工作区不为空时，MUST 说明仍留有的未提交变更及修改了哪些内容。

#### Scenario: 工作区已空
- **WHEN** 本轮只创建 commit，全部成功，且 `git status --short` 为空
- **THEN** 回应 MUST 以「已提交完成。」开头
- **AND** 结尾 MUST 使用带实际仓库名和分支的推送提议句子

#### Scenario: 工作区还有改动
- **WHEN** 本轮只提交了部分条目，其余改动仍在工作区
- **THEN** 回应 MUST 以「已提交完成。」开头
- **AND** MUST 说明工作区仍留有的未提交变更
- **AND** MUST NOT 使用工作区已空时的那句推送提议

### Requirement: 只推送成功时 SHALL 使用推送完成回应
提交已在上一轮完成、本轮只 push 且成功时，开头 MUST 为「已推送完成。」。中间 MUST 给出分支和仓库地址。没有其他未推送 commit 时，结尾 MUST 为「当前已无未推送 commit。」。仍有未推送 commit 时，MUST 列出这些 commit 的 hash、标题和变更。

#### Scenario: 本次 push 之后没有剩余未推送 commit
- **WHEN** 本轮只执行 push 并成功，且没有剩下的未推送 commit
- **THEN** 回应 MUST 以「已推送完成。」开头
- **AND** MUST 给出分支和去掉 `.git` 的仓库地址
- **AND** 结尾 MUST 为「当前已无未推送 commit。」

#### Scenario: 仍有不属于这次 push 的 commit
- **WHEN** 本轮 push 成功，但另有已提交且未推送的 commit
- **THEN** 回应 MUST 列出这些 commit 的 hash、标题和变更

### Requirement: 提交并推送都成功时 SHALL 使用合并回应
同一轮提交并 push 且都成功时，开头 MUST 为「已提交并推送完成。」。中间 MUST 先列本次 commit，再给分支和仓库地址。工作区为空且没有其他未推送 commit 时，结尾 MUST 为「当前工作区已无未提交变更和未推送 commit。」。工作区不为空且仍有已提交未推送的 commit 时，MUST 同时说明未提交变更和这些未推送 commit。

#### Scenario: 工作区与未推送提交都已清空
- **WHEN** 同一轮里拟提交 commit 全部创建并 push 成功，工作区为空，也没有其他未推送 commit
- **THEN** 回应 MUST 以「已提交并推送完成。」开头
- **AND** 结尾 MUST 为「当前工作区已无未提交变更和未推送 commit。」

#### Scenario: 工作区和工作区之外的提交都还有剩余
- **WHEN** 同一轮提交并 push 成功，但工作区仍有未提交变更，且另有未推送 commit
- **THEN** 回应 MUST 同时说明这两部分剩余内容

### Requirement: 异常恢复 SHALL 只覆盖四类故障
异常恢复规范 MUST 只在需要撤回 commit、无法按 hunk 提交、提交成功但内容与预览不一致，或 push 失败时使用。没有这些异常时 MUST NOT 按该规范行动。规范没有覆盖的异常，技能 MUST 自行判断并处理。

#### Scenario: 提交和推送都正常
- **WHEN** 本轮没有撤回、hunk 失配、内容不一致或 push 失败
- **THEN** 技能 MUST NOT 执行异常恢复中的 reset、revert 或 force push

#### Scenario: 出现规范没有写到的异常
- **WHEN** 故障不属于上述四类
- **THEN** 技能 MUST 自行判断并处理

### Requirement: 撤回 commit SHALL 区分是否已经推送
撤回尚未 push 的 commit 时 MUST 使用 `git reset --soft`，MUST NOT `git restore`。撤回已经 push 的 commit 时，MUST 向用户说明并等待用户确认，再在 `git revert` 与 `git reset` 加 force push 之间选择。已经 push 的 commit 与本地工作区改动会发生冲突时，MUST 说明情况并按用户要求操作。

#### Scenario: 撤回刚创建且未推送的 commit
- **WHEN** 需要撤回本次已创建但尚未 push 的 commit
- **THEN** 技能 MUST 使用 `git reset --soft`
- **AND** MUST NOT `git restore`

#### Scenario: 需要撤回已经推送的 commit
- **WHEN** 需要撤回的 commit 已经 push
- **THEN** 技能 MUST 先说明并等待用户确认
- **AND** MUST NOT 自行选择 `git revert` 或 force push

### Requirement: 无法按 hunk 提交时 SHALL 停止后续提交
按预览标明的 hunk 提交时，若补丁对不上该文件当前相对 `HEAD` 的 diff、路径是二进制、路径是 rename 或 copy 同时还要拆内容，或路径尚未进入 HEAD，技能 MUST 停止后续提交并说明原因。

#### Scenario: 补丁对不上当前 diff
- **WHEN** 预览要求按 hunk 提交，但补丁对不上该文件相对 `HEAD` 的 diff
- **THEN** 技能 MUST 停止后续提交并说明原因

#### Scenario: 路径还没有进入 HEAD
- **WHEN** 预览要求按 hunk 拆分一个尚未进入 HEAD 的路径
- **THEN** 技能 MUST 停止后续提交并说明原因

### Requirement: 提交结果与预览不一致时 SHALL 停止推送
commit 已经创建成功但内容与该条预览不一致时，MUST NOT push，MUST NOT 使用成功开头，并 MUST 向用户说明。

#### Scenario: 已创建的 commit 与预览不同
- **WHEN** 某条 commit 已经创建成功，但内容与该条预览不一致
- **THEN** 技能 MUST NOT push
- **AND** MUST NOT 使用成功开头
- **AND** MUST 向用户说明

### Requirement: push 失败时 SHALL 说明原因并停止自行重试
push 失败时 MUST 说明原因，且 MUST NOT 自行执行 `git push -u`、`--force` 或 `--force-with-lease`。

#### Scenario: push 被远程拒绝
- **WHEN** 本次 commit 已创建成功，但随后的 push 失败
- **THEN** 技能 MUST 说明无法 push 的原因
- **AND** MUST NOT 自行追加 `-u`、`--force` 或 `--force-with-lease`
