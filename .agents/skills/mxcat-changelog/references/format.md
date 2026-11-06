# CHANGELOG 格式

## 约束范围

- 仅约束新增 CHANGELOG
- 无特殊要求时不改动已有内容

## CHANGELOG 文件位置

- 如项目中已有 CHANGELOG 文件，则沿用，如没有则在项目根目录进行创建

## 标题

- CAHNGELOG 的一级标题为 `# 更新文档`，全文只有一个一级标题
- 二级标题为版本节标题，形态为 `## X.Y.Z（YYYY-MM-DD）`（`X.Y.Z` 为版本号，全角括号 `（）` 内为发布日期）；全文版本节自上而下按发布日期递减排列
- 二级标题对应的内容形态为 `- :shortcode: (scope) 描述` 或 `- type(scope): subject`（条目类型为 shortcode 或 Conventional Commits 文字类型，半角括号内为 `scope`，其后为描述）
- 节点之间保留一个空行，标题和内容之间保留一个空行

## 示例

```md
# 更新文档

## 0.7.0（2026-10-13）

- :sparkles: (journey) 首页改为滚动驱动的三维路线，覆盖导航、温室、猫窝、室内作品和熄灯底栏
- :sparkles: (loading) 等场景就绪后再结束加载
- :sparkles: (visits) 记录首页访问次数和人数
- :sparkles: (works) 增加作品占位页，供画框在新标签打开
- :sparkles: (content) 增加场景用的植物、技能、书、画框内容，以及作品预览图和技能图标
- :wrench: (deps) 改用 yarn 并加入三维场景依赖
- :wrench: (skills) 加入代码规范与提交技能
- :wrench: (git) 用 Git LFS 跟踪 blend 源文件
- :memo: (openspec) 添加沉浸式博客框架的滚动路线、温室、猫窝、作品位和访问统计规格

## 0.1.0（2026-10-13）

- :wrench: (cursor) 添加 OpenSpec 命令与技能
- :memo: (openspec) 添加首次访问加载规格与变更
- :wrench: 迁移至 pnpm 并更新工程配置
- :sparkles: (loading) 添加首次访问加载体验

## 0.0.0（2026-09-29）

- :tada: (init) 基于 Create Next App 初始化 Next.js 工程
```
