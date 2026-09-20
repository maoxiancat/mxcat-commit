## 1. 空壳可安装

- [x] 1.1 创建 `skills/mxcat-commit/SKILL.md`，frontmatter 仅含 `name: mxcat-commit` 与包含提交触发短语的 `description`，且不含 `disable-model-invocation`
- [x] 1.2 在该 `SKILL.md` 写入 `## 安装` 章节：`npx -y skills add <owner>/mxcat-commit --skill mxcat-commit`，以及 `-g -a cursor -a claude-code` 示例；owner 使用占位符 `<owner>`
- [x] 1.3 创建仓库根 `README.md`：说明这是公开 `mxcat-commit` 技能源，并给出同样的安装命令
- [x] 1.4 创建 `skills/mxcat-commit/README.md` 与 `CHANGELOG.md` 骨架，安装命令与根 README 一致；此时不要写 single/batch 流程正文

## 2. 提交约定真源

- [x] 2.1 新增 `skills/mxcat-commit/references/commit-convention.md`，写明 cz-emoji header 骨架、shortcode、必写 scope 与 `!` 位置
- [x] 2.2 在约定文档中写明 subject/body 默认简体中文、本轮可覆盖为英文，以及 `BREAKING CHANGE:` 字段名保持英文
- [x] 2.3 在约定文档中明确禁止 `AI-Co-Authored-By`、`Co-authored-by` / `Co-Authored-By` 与 `Jira-Refs:`，并给出含空行的完整消息示例

## 3. 主文档路由器

- [x] 3.1 扩展 `SKILL.md`：默认按逻辑分批（batch）；仅当用户明确要求合为一条 commit 时走 single
- [x] 3.2 在 `SKILL.md` 写入预览门禁摘要：确认前禁止 `git commit`；启动语不等于确认；修改预览须重出
- [x] 3.3 在 `SKILL.md` 摘要消息硬约束（header 骨架、默认中文、禁止 AI/Jira 页脚），并指向 `commit-convention.md`
- [x] 3.4 在 `SKILL.md` 加入「何时读取哪份 reference」表，链接到 single、batch、convention、types、troubleshooting（后三份此时可以先占位文件名）

## 4. 单次提交流程

- [x] 4.1 新增 `skills/mxcat-commit/references/single-commit.md`：分析输入范围、写中文标题正文、填写预览卡（标题、正文、含改动范围的解释）
- [x] 4.2 在 single guide 写确认词、修改预览不提交、以及「完整标题 + 直接提交」才可跳过预览
- [x] 4.3 在 single guide 写确认后的 `printf` + `git commit --file` 推荐写法，以及提交后 header/空行自检（不含 AI trailer 校验）

## 5. 分批提交流程

- [x] 5.1 新增 `skills/mxcat-commit/references/batch-commit.md`：默认按逻辑分批、输入为整棵工作树，用常规 git 命令
- [x] 5.2 在 batch guide 要求一次出示 1/N…N/N 预览卡，整单确认后按序 `git add` + `git commit --file`
- [x] 5.3 在 batch guide 写明中途 hook 失败则停止后续提交，并报告已成功、失败与未尝试条目

## 6. 附录 reference

- [x] 6.1 新增 `references/cz-emoji-types.md`（完整 cz-emoji 类型表）
- [x] 6.2 新增 `references/troubleshooting.md`：自检失败、hook 失败、空行问题；不要写脚本回滚或 AI trailer 修复
- [x] 6.3 核对 `SKILL.md` 的 reference 表链接全部可点，且主文档仍保持路由器而不展开附录正文

## 7. GitHub 发布准备

- [x] 7.1 确认安装命令与文档仍使用 `<owner>` 占位符，或在用户给出真实 GitHub owner 后替换所有安装示例
- [x] 7.2 在 README 写明验证方式：`npx skills add <source> --list` 应列出 `mxcat-commit`（远程未创建前可标注为待验证）
- [x] 7.3 确认安装文案只使用公开 `npx skills`，且技能包不依赖外部批次脚本
