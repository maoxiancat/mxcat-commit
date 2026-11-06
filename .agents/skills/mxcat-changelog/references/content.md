# 新增内容确定

## 版本号

- 版本号形如 `X.Y.Z`。确定版本号时先读仓库提交和已有 tag。已有 tag 的进度超出更新文档里已记录的版本时，先按 tag 和 commit 补全缺失的版本节，再把该进度之后的提交和尚未提交的改动合在一起，预测下一节标题里的版本号。
- 预测出的版本号只用于写入更新文档的版本节标题。不创建、不移动、不删除 git tag。
- 用户已经给出 `X.Y.Z` 时，标题用用户给的版本号，不再预测。

### 读取判断 CHANGELOG 记录进度

- 比较前去掉前缀和后缀，如`v`等，按 `X`、`Y`、`Z` 的数字比较。

```bash
git tag --list
git for-each-ref --sort=v:refname --format '%(refname:short) %(creatordate:short)' refs/tags
```

- 更新文档里已记录的版本，是 `# 更新文档` 下各节标题 `## X.Y.Z（YYYY-MM-DD）` 中的 `X.Y.Z`。其中最高的一个是已记录版本。还没有版本节时，已记录版本为空。

### 补全

- 高于已记录版本的 tag 都要先补进更新文档，再做预测。低于或等于已记录版本的 tag 不补。
- 按版本从低到高，每个待补 tag 单独成节
- 标题版本号是去掉前缀和后缀后的 `X.Y.Z`
- 日期用该 tag 的 `creatordate`，取本地日历日期

### 预测

- 起点是补全之后的最高版本。没有 tag、也没有已记录版本时，起点是 `0.0.0`。
- 只看起点之后的提交和尚未提交的改动。加哪一档取决于这些改动影响的范围和量。范围是改动波及的面有多广，量是这个范围内改动有多少。
- 同一批只抬一档。范围和量对得上更高一档时取更高档，顺序是 `X`、`Y`、`Z`。同一档只加一。
- `X` 加一：影响的范围广，量也大。`Y` 和 `Z` 归零。
- `Y` 加一：影响的范围限于一部分，量居中。`Z` 归零。
- `Z` 加一：影响的范围窄，量小。
- `1.0.0`为特殊节点，在已有 tag 未达到时，预测的不能达到`1.0.0`

## 日期

- 用户没指定日期时，用写入更新 CHANGELOG 当天的本地日历日期。
- 补全时用该 tag 的 `creatordate`，取本地日历日期

## 条目类型

- 条目类型有两种 shortcode 和 Conventional Commits 文字类型，两套不混写
- 如项目中已使用 shortcode 或 Conventional Commits 文字类型，则沿用对应的种类，如没有则使用 shortcode
- 使用 shortcode 时，具体类型列表见 [emoji-shortcode-list.md](modify-type-list/emoji-shortcode-list.md)。
- 使用 Conventional Commits 文字类型时，具体类型列表见 [conventional-commits-list.md](modify-type-list/conventional-commits-list.md)。

## scope

- `scope`标识变化落在哪一块，形态是一段不含空白的全小写英文标识，可以含连字符，放在半角括号里
- 不按文件路径拼接，也不并列多个范围，如`(auth,api)`

## 描述

- 描述使用简体中文，以精确规范的语言对新增的功能、造成的修改进行描述。

### 示例

```md
- :sparkles: (content) 增加场景用的植物、技能、书、画框内容，以及作品预览图和技能图标
- :wrench: (skills) 加入代码规范与提交技能
```

```md
- feat(loading): 等场景就绪后再结束加载
```
