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
- `scope` 取主要改动所在的模块、目录或功能面，用短词，不要空格
- `!` 是独立的 breaking 标记；出现时位于 `(scope)` 之后、subject 之前，两侧各一空格

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
✨ (charts) 增加空数据占位
feat(charts): 增加空数据占位

:sparkles: (charts) 增加空数据占位

- 折线图无数据时展示占位图

Jira-Refs: DATA-6755

AI-Co-Authored-By: Codex
```

上面这些都不合规：缺少 `(scope)`、Unicode emoji、文字 type 前缀、`Jira-Refs:`、`AI-Co-Authored-By:`。

## 常用类型

| Shortcode | 语义 |
|---|---|
| `:sparkles:` | 新功能 |
| `:bug:` | 修复 |
| `:memo:` | 文档 |
| `:recycle:` | 重构 |
| `:zap:` | 性能 |
| `:white_check_mark:` | 测试 |
| `:wrench:` | 配置或杂项 |
| `:truck:` | 移动或重命名 |
| `:fire:` | 删除 |

更完整的类型表见 `cz-emoji-types.md`。
