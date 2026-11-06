# commit 标题规范

## 语言

- 未声明应使用语言种类时，subject 使用简体中文，本轮明确要求使用英文或其他语言的时才使用对应语言
- 语言种类要求只影响 subject 和 body，type 和 scope 不影响 

## 标题形式

- 允许的标题骨架为
```text
:type: (scope) subject
:type: (scope) ! subject
```
- type 使用 shortcode 或 Conventional Commits 文字类型，两套不混用，具体使用哪种参考对应仓库之前 commit 使用的是哪种，如果均不是则使用 shortcode
- type 使用 shortcode 时参考 [emoji-shortcode-list.md](modify-type-list/emoji-shortcode-list.md)，使用 Conventional Commits 文字类型时参考 [conventional-commits-list.md](modify-type-list/conventional-commits-list.md)
- `scope` 用于描述修改影响的范围，必须写成 `(scope)`，不得省略括号。
- `(scope)` 括号内必须是单段小写名称，只含小写字母、数字与连字符。不得含空格、制表符、大写字母、下划线或逗号，不得写成 `(auth,api)`。
- `!` 是独立的 breaking 标记，当这次提交是破坏性变更时使用，位于 `(scope)` 之后、subject 之前，两侧各一空格，均使用半角感叹号。

## 示例

```text
:sparkles: (charts) 增加空数据占位
:bug: (login) 修复验证码过期后仍可提交
:lipstick: (dashboard) 统一卡片圆角与阴影
:memo: (readme) 补充本地开发环境说明
:recycle: (auth) 抽离令牌校验为独立模块
:zap: (query) 减少列表接口的 N+1 查询
:construction_worker: (github-actions) 缓存依赖以缩短流水线
:fire: (legacy-api) 移除 v1 导出端点
:boom: (api) ! 登录响应改为只返回访问令牌
:sparkles: (charts) add empty-state placeholder
```

```text
:feat: (charts) 增加空数据占位
:fix: (login) 修复验证码过期后仍可提交
:docs: (readme) 补充本地开发环境说明
:refactor: (auth) 抽离令牌校验为独立模块
:perf: (query) 减少列表接口的 N+1 查询
:ci: (github-actions) 缓存依赖以缩短流水线
:chore: (deps) 升级 eslint 至当前主版本
:feat: (api) ! 登录响应改为只返回访问令牌
:feat: (charts) add empty-state placeholder
```

```text
:sparkles: (charts) 增加空数据占位

- 折线图没有数据点时展示占位图
- 占位图沿用当前图表的宽高
```

```text
:sparkles: (charts) add empty-state placeholder

- show a placeholder when the line chart has no data points
- keep the placeholder the same size as the chart
```

```text
:boom: (api) ! 登录响应改为只返回访问令牌

- 成功响应只保留 accessToken 字段
- 响应体里去掉 refreshToken

BREAKING CHANGE: 登录接口不再在 JSON 里返回 refreshToken
```

```text
:boom: (api) ! return only the access token from login

- keep only the accessToken field on success
- remove refreshToken from the response body

BREAKING CHANGE: login no longer returns refreshToken in JSON
```
