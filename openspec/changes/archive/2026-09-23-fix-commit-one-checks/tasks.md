## 1. validate

- [x] 1.1 改 `scripts/validate`：标题之后、第一处空行之前出现非空行则失败；两个空行再正文、以及正文与 `BREAKING CHANGE:` 之间缺空行，不因此失败。去掉行首空白后再拒绝 `AI-Co-Authored-By:`、`Co-authored-by:`、`Jira-Refs:`。括号内 scope 必须是单个小写 token（字母、数字、连字符），`(auth,api)` 失败
- [x] 1.2 用同一规则改 `scripts/validate.ps1`

## 2. commit_one

- [x] 2.1 改 `scripts/commit_one`：比较前把参数和 `git show` 收成仓库相对路径（去掉 `./`，补上当前目录前缀，折叠 `.` 与 `..`）。目录参数，或规范化后相对 `HEAD` 没有差异的路径，在 `git commit` 之前非 0 退出。提交后对照使用同一套路径；仍不一致时不 `reset`
- [x] 2.2 用同一规则改 `scripts/commit_one.ps1`

## 3. 测试

- [x] 3.1 覆盖消息：粘连且后面还有 `BREAKING CHANGE:` 前的空行时 `validate` 非 0；只有标题、标题加空行加正文、两个空行再正文、正文后紧跟 `BREAKING CHANGE:` 时为 0。行首空白的 `Co-authored-by:` 与 `(auth,api)` 非 0；`(charts)` 与 `(mxcat-commit)` 为 0
- [x] 3.2 用临时仓库覆盖：`./` 前缀和非仓库根目录下的相对路径在有差异时提交成功且退出码 0。目录参数、夹带未改动文件时不创建 commit。重命名同时给出旧路径和新路径时预检不拒绝

## 4. 文档

- [x] 4.1 改 `references/troubleshooting.md`：粘连不被后面的空行洗白；目录和未改动路径在提交前失败、commit 未创建；提交后对照失败时 commit 仍保留且不 reset
- [x] 4.2 用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
