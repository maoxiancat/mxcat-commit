# 成功回应规范

- 当提交/push 成功时，按本文要求输出回应。
- 任一条 commit 失败、自检失败、没有上游或 push 失败时，不要用本文的成功开头。
- 成功回应分为三种情况
    - 本轮只执行提交且拟提交 commit 全部提交成功时依照 [拟提交 commit 全部提交成功时](#提交成功回应) 来进行回应
    - 提交已在上轮完成；本轮只执行 push 且 push 成功时依照 [仅 push 成功时](#push-成功回应) 来进行回应
    - 同一轮既提交又 push 且均成功时依照 [提交并 push 都成功时](#提交并-push-成功回应) 来进行回应

## 回应共同规范

- 仅使用只读命令，不改 index、HEAD 或工作区
- 只列出本次实际提交/push 的 commit
- 每组 commit 信息之间保留一个空行
- 成功回应中的 commit 信息包括三部分
    - `Commit Hash：` 使用短 hash
    - `标题：` 完整 header
    - `变更：` 影响文件数、行数
- Commit Hash 使用短 hash 也就是缩写的 hash 值，使用 `git log --oneline` 获取
- 标题使用提交里的完整 header，使用 `git log --oneline` 获取
- 文件数与行数只有增加时写成 `+N 行`；只有删除时写成 `-N 行`；同时有增加和删除时写成 `+A / -B 行`，使用 `git show --stat` 获取
- 工作区情况使用 `git status --short` 获取
- 所处分支使用 `git rev-parse --abbrev-ref HEAD` 获取
- 仓库名使用 `git remote get-url origin` 获取失败时省略该行
- 仓库地址使用 `git remote get-url origin` 获取，并去掉末尾 `.git`，获取失败时省略该行

## 提交成功回应

- 开头为固定文案「已提交完成。」。
- 中间为提交成功 commit 的信息
- 当工作区为空时，结尾输出「当前工作区已无未提交变更，若要推送到 仓库名/所处分支，可以说一声我帮你执行 git push。」，不为空时说明工作区未提交的变更，输出「工作区仍留有未提交变更：修改了哪些内容」

- 示例

示例前提：两条 commit 都已提交。`git status --short` 为空。当前分支 `main`，`git remote get-url origin` 为 `https://github.com/mxcat/charts.git`，仓库名为 `charts`。

```text
已提交完成。

- Commit Hash： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行

- Commit Hash： e4f5a6b
- 标题： :bug: (charts) 修复横轴刻度重叠
- 变更： 1 个文件，+8 / -3 行

当前工作区已无未提交变更，若要推送到 charts/main，可以说一声我帮你执行 git push。
```

示例前提：只提交了空数据占位这一条。`git status --short` 仍有 ` M src/charts/LineChart.tsx` 与 ` M src/charts/Axis.tsx`，横轴刻度改动留在工作区。

```text
已提交完成。

- Commit Hash： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行

工作区仍留有未提交变更
- 修改了横轴刻度间隔。`src/charts/LineChart.tsx`、`src/charts/Axis.tsx`
```

## push 成功回应

- 开头为固定文案「已推送完成。」。
- 中间为所处分支和仓库地址
- 无已提交未推送的 commit 时，结尾输出「当前已无未推送 commit。」，有已提交未推送的 commit 时说明这些 commit，输出「仍留有未推送的 commit：commit 信息」

- 示例

示例前提：上轮提交的 `a1b2c3d`、`e4f5a6b` 本轮已推送。`git status --short` 为空，也没有更早的未推送 commit。当前分支 `main`，origin 为 `https://github.com/mxcat/charts.git`。

```text
已推送完成。

- 分支： main
- 仓库地址： https://github.com/mxcat/charts

当前已无未推送 commit。
```

示例前提：本轮已推送 `a1b2c3d`。`e4f5a6b` 已在本地提交，不属于这次 push，因此仍留在分支上。当前分支 `main`，origin 为 `https://github.com/mxcat/charts.git`。

```text
已推送完成。

- 分支： main
- 仓库地址： https://github.com/mxcat/charts

仍留有未推送的 commit
- Commit Hash： e4f5a6b
- 标题： :bug: (charts) 修复横轴刻度重叠
- 变更： 1 个文件，+8 / -3 行
```

## 提交并 push 成功回应

- 开头为固定文案「已提交并推送完成。」。
- 中间为提交并推送成功 commit 的信息
- 中间和结尾之间为所处分支和仓库地址
- 当工作区为空且无已提交未推送的 commit 时，输出「当前工作区已无未提交变更和未推送 commit。」，不为空且有已提交未推送的 commit 时说明工作区未提交的变更以及已提交未推送的 commit，输出「工作区仍留有未提交变更：修改了哪些内容」「仍留有已提交未推送的 commit：commit 信息」

- 示例

示例前提：两条 commit 都已提交并推送。`git status --short` 为空，没有剩余未推送 commit。当前分支 `main`，origin 为 `https://github.com/mxcat/charts.git`。

```text
已提交并推送完成。

- Commit Hash： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行

- Commit Hash： f6a7b8c
- 标题： :fire: (charts) 移除废弃的图例开关
- 变更： 1 个文件，-12 行

- 分支： main
- 仓库地址： https://github.com/mxcat/charts

当前工作区已无未提交变更和未推送 commit。
```

示例前提：只提交并推送了空数据占位这一条。`git status --short` 仍有 ` M src/charts/LineChart.tsx` 与 ` M src/charts/Axis.tsx`，横轴刻度改动还留在工作区。`c9d0e1f` 已在本地提交，不属于这次 push，因此仍留在分支上。当前分支 `main`，origin 为 `https://github.com/mxcat/charts.git`。

```text
已提交并推送完成。

- Commit Hash： a1b2c3d
- 标题： :sparkles: (charts) 增加空数据占位
- 变更： 2 个文件，+40 行

- 分支： main
- 仓库地址： https://github.com/mxcat/charts

工作区仍留有未提交变更
- 修改了横轴刻度间隔。`src/charts/LineChart.tsx`、`src/charts/Axis.tsx`

仍留有未推送的 commit：
- Commit Hash： c9d0e1f
- 标题： :memo: (readme) 补充本地开发环境说明
- 变更： 1 个文件，+6 行
```
