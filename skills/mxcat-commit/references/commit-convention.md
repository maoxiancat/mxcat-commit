# 提交约定（cz-emoji）

本文只描述 `mxcat-commit` **定稿后的提交消息**必须满足的规范结果：标题骨架、描述语言、body 空行、允许的 footer。

以下内容不属于本文：

- 预览卡、确认词、何时运行 `git commit`
- `printf` / `--file` 等命令写法
- hook 故障排查

那些内容按需读取 `single-commit.md`、`batch-commit.md`、`troubleshooting.md`。

## 摘要

- 标题以 cz-emoji **shortcode** 开头，emoji 表达 Conventional Commits 的 `type`
- `scope` **必写**，且必须是 `(scope)`
- subject 与 body **默认简体中文**；用户本轮明确要求英文时再覆盖
- 破坏性变更用独立的 `!` 和可选的 `BREAKING CHANGE:` footer
- **禁止** `AI-Co-Authored-By:`、`Co-authored-by:` / `Co-Authored-By:`、`Jira-Refs:`
- 不读取任何语言配置文件

## Header

允许的标题骨架只有这两种：

```text
:emoji: (scope) subject
:emoji: (scope) ! subject
```

硬约束：

- emoji 必须使用 shortcode，例如 `:bug:`、`:sparkles:`，不得使用 Unicode ✨
- 不得使用 `feat(scope): subject` 这类文字 type 前缀
- `scope` 必写，必须写成 `(scope)`，不得省略
- `(scope)` 括号内必须是单个小写 token，只含小写字母、数字与连字符；连字符不能在开头、结尾或连续出现。不得含空格、制表符、大写字母、下划线或逗号，不得写成 `(auth,api)`。自检按此拒绝，且不创建该条 commit
- `!` 是独立的 breaking 标记；出现时位于 `(scope)` 之后、subject 之前，两侧各一空格

选词（生成时遵守；自检不验选词对不对，`(misc)`、`(all)`、`(update)`、`(wip)` 仍会通过。中文 scope 不是小写 token，`:sparkles: (图表) …` 会被判 header 不合格）：

- 一个小写英文短词。连字符只保留源名字里已有的（例如包名 `mxcat-commit`），不要把说明收成短横线短语
- 按这条 commit 的主语选，不按文件路径拼接，也不维护允许名单：产品面、页面或功能用该面短词；共享层或基础设施用该层短词；规范或流程工具用该工具短词
- 宿主仓库一批 skill 快照用 `(skills)`；只改某一个 skill 用它的包名
- 看不出单一主面就拆成多条 commit，不要写 `(misc)`、`(all)`、`(update)`、`(wip)`
- subject 即使用中文，scope 仍用英文短词

## 语言

未声明时，subject 与 body 使用简体中文。即使用户这轮用英文说话、仓库文档是中文，只要没说「用英文写 commit」，描述仍用中文。

用户本轮明确要求英文（或其他语言）时，subject 与 body 改用所要求语言。

语言只影响人类描述：

- header 的 subject
- body 的 bullet 文本
- `BREAKING CHANGE:` **之后**的说明

不改变协议字段：

- `:emoji:` shortcode
- `(scope)`
- `!`
- `BREAKING CHANGE:` 字段名（始终英文）

默认中文：

```text
用户：帮我提交

正确：
:sparkles: (charts) 增加空数据占位

错误：
:sparkles: (charts) add empty-state placeholder
```

本轮要求英文：

```text
用户：用英文写 commit message

正确：
:sparkles: (charts) add empty-state placeholder
```

## Body

body 可选。若存在：

- 使用 `- ` 开头的 bullet 列表，保持简洁
- header 与 body 之间必须恰好一个空行
- 若还有 footer，body 与 footer 之间必须恰好一个空行

## Footer

唯一允许的可选 footer 是 `BREAKING CHANGE:`。

- 字段名必须是 `BREAKING CHANGE:`（英文）
- 冒号后的描述遵循当前语言偏好（默认简体中文）
- 与上方内容之间保留一个空行

禁止输出下列任意一行，即使上下文里出现 Jira key、URL 或 AI 署名习惯：

- `AI-Co-Authored-By:`
- `Co-authored-by:`
- `Co-Authored-By:`
- `Jira-Refs:`

## 完整示例

### 普通标题

```text
:bug: (charts) 拒绝重复导出
```

### breaking 标题

```text
:sparkles: (charts) ! 改为立即失败
```

### 带 body 的默认中文消息（注意空行）

```text
:sparkles: (charts) 增加空数据占位

- 折线图无数据时展示占位图
- 导出入口改为禁用而不是报错
```

### 带 BREAKING CHANGE 的完整消息（注意空行，且无 AI / Jira 页脚）

```text
:bug: (charts) ! 拒绝重复导出

- 重复导出请求改为立即失败
- 不再静默覆盖已有文件

BREAKING CHANGE: 重复导出现在会直接报错
```

### 错误示例

```text
:sparkles: 增加空数据占位
:sparkles: (my scope) 增加空数据占位
:sparkles: (auth,api) 增加空数据占位
:sparkles: (misc) 增加空数据占位
✨ (charts) 增加空数据占位
feat(charts): 增加空数据占位

:sparkles: (charts) 增加空数据占位

- 折线图无数据时展示占位图

Jira-Refs: DATA-6755

AI-Co-Authored-By: Codex
```

上面这些都不合规：缺少 `(scope)`、括号内空白、并列 scope、占位词 `misc`、Unicode emoji、文字 type 前缀、`Jira-Refs:`、`AI-Co-Authored-By:`。

## 常用类型

| Shortcode | 语义 |
|---|---|
| `:sparkles:` | 新功能 |
| `:bug:` | 修复 |
| `:lipstick:` | 界面和样式 |
| `:art:` | 代码结构或格式 |
| `:lock:` | 安全修复 |
| `:heavy_plus_sign:` | 添加依赖 |
| `:memo:` | 文档 |
| `:recycle:` | 重构 |
| `:zap:` | 性能 |
| `:white_check_mark:` | 测试 |
| `:wrench:` | 配置 |
| `:truck:` | 移动或重命名 |
| `:fire:` | 删除 |

选词（生成时遵守；自检不验 emoji 语义）：

- 界面或样式用 `:lipstick:`
- 代码结构或格式用 `:art:`
- 安全修复用 `:lock:`；普通缺陷仍用 `:bug:`
- 添加依赖用 `:heavy_plus_sign:`
- 配置用 `:wrench:`

依赖的升级、降级、移除或锁版本，只改文案或字面量，以及 CI、国际化，必须打开 `cz-emoji-types.md` 再选，不要硬套进上表。只改文案用其中的 `:speech_balloon:`。界面改动同时改到文案时，仍用 `:lipstick:`。
