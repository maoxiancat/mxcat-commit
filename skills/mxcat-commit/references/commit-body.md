# commit 内容规范

## 语言

- 未声明应使用语言种类时，body 使用简体中文，本轮明确要求使用英文或其他语言的时才使用对应语言
- 语言种类要求只影响 subject 和 body，type 和 scope 不影响 

## body 描述规范

- Body 保持 bullet 风格，并用精炼的语言进行描述。
- Header 和正文之间必须保留一个空行。
- 若存在 footer，正文和 footer 之间必须保留一个空行。
- 不要输出 `AI-Co-Authored-By:`、`Co-authored-by:`、`Co-Authored-By:`、`Jira-Refs:`等 AI 署名习惯。
- 若存在 `BREAKING CHANGE:`，字段名保持英文；其后的描述文本遵循当前语言。

## 示例

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