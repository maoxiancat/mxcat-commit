## Context

仓库目前只有 OpenSpec 脚手架，没有技能包、git remote 或主 specs。行为合同见 `proposal.md` 与 `specs/*/spec.md`。技能用渐进式披露：`SKILL.md` 作路由器，细节下沉到 `references/`，分批提交走常规 git 命令。

## Goals / Non-Goals

**Goals:**

- 用 `skills/mxcat-commit/` 作为 `npx skills` 可发现的单一技能包。
- 把 `SKILL.md` 做成路由器：分流、预览门禁摘要、消息硬约束摘要、按读取时机指向 references。
- 用文档约束 agent 行为（预览卡、确认词、中文默认、常规 git 命令），而不是用脚本强制。
- 按切片落地，每一刀可独立审查，避免一次生成整包。

**Non-Goals:**

- 不引入批次执行器、shadow worktree、hook 吸收或 inventory JSON。
- 不引入语言配置文件。
- 不在本次设计中创建 GitHub 仓库（安装命令先写 owner，远程另接）。
- 不把本仓库做成多技能目录；v1 只有 `mxcat-commit` 一个包。

## Decisions

### Decision: 源码布局对齐 Agent Skills 扁平 `skills/<name>/`
技能正文放在 `skills/mxcat-commit/`，而不是仓库根 `SKILL.md`。这样 `npx skills add <owner>/mxcat-commit --skill mxcat-commit` 能按标准扫描规则发现，也方便以后加第二个技能。

Alternatives considered:

- 仓库根直接放 `SKILL.md`：单技能时可行，但仓库名与 OpenSpec 脚手架混在一起，扫描边界更糊。
- 只放 `.cursor/skills/`：对 Cursor 项目级可见，但不是 `npx skills` 的源目录约定。

### Decision: 公开 CLI 用 `npx -y skills`
安装段只写 GitHub shorthand 与 `-g` / `-a` 示例。canonical 安装落点由 skills CLI 决定（通常是 `.agents/skills/mxcat-commit` 再软链到各 Agent）。

Alternatives considered:

- 让用户手动 `cp`：无法满足「用 npx 下载、多 Agent」的目标。

### Decision: 按读取时机拆 references，而不是按主题拆
默认加载 `SKILL.md`。默认走 batch（按逻辑分批，输入为整棵工作树）；仅当用户明确要求合为一条 commit 时走 single。选定 single 后读 `references/single-commit.md`；选定 batch 后读 `references/batch-commit.md`；规范真源是 `references/commit-convention.md`；类型不够用才读 `references/cz-emoji-types.md`；失败才读 `references/troubleshooting.md`。

预览门禁属于技能硬约束，摘要留在 `SKILL.md`，单次/分批如何填预览卡的细节放进对应 guide。

Alternatives considered:

- 把全部流程写进 `SKILL.md`：默认加载层会过长。
- 按「格式 / 例子 / hook」主题拆文件：agent 不知道何时该读。

### Decision: 预览卡是对话产物，不是 JSON 计划文件
Agent 在聊天里输出 Markdown 预览。v1 不写 `/tmp/plan.json`，也没有 preview-plan CLI。Batch 一次出齐 1/N…N/N，一次确认后按序 `git add` + `git commit --file`。提交消息推荐 `printf` + `--file`，避免空行丢失。

确认词以用户自然语言为准：确认 / 可以提交 / lgtm / 就这样。修改请求只更新预览。

Alternatives considered:

- 引入 plan JSON + 脚本校验：超出文档约束的范围。
- 逐条确认：更安全但更烦；v1 选整单确认，失败则停在当前条。

### Decision: 默认中文写在约定文档里，不做成项目配置
没有 `mxcat-commit.language` 文件。规则是：未声明则简体中文；本轮明确要求英文则覆盖。避免再引入 local config 门禁。

Alternatives considered:

- 再做一份项目级语言配置：对公开个人技能过重。
- 完全跟随对话语言：中英混杂时不稳定；显式默认中文更可测。

### Decision: 实现顺序锁成七刀，apply 时一次只做一刀
任务分组必须对应：空壳 → 约定 → 路由器 → single → batch → 附录 → GitHub 占位/远程。每一刀合并后技能仍应可阅读；空壳阶段允许流程正文不完整，但 frontmatter 与安装段必须合法。

Alternatives considered:

- 一次生成全部 markdown：用户已明确拒绝，出错面太大。
- 先写完所有 references 再写 `SKILL.md`：路由器无法在中途被审查。

## Risks / Trade-offs

- [Risk] 无事务式 apply，batch 中途 hook 失败会留下部分 commit。  
  Mitigation: 规范要求停止并报告已成功 / 失败 / 未尝试；不假装整单完成。

- [Risk] 预览门禁只靠文档，agent 可能仍直接提交。  
  Mitigation: `SKILL.md` 把「禁止在确认前 `git commit`」放在默认加载层，并在 single/batch guide 开头重复。

- [Risk] GitHub owner 未知，安装命令暂时不可复制即用。  
  Mitigation: 统一占位符 `<owner>`；最后一刀在有远程后再替换，不在前几刀伪造账号。

- [Risk] Cursor 全局目录曾出现 `~/.agents/skills` 与 `~/.cursor/skills` 链接不一致。  
  Mitigation: 文档同时给出 `-a cursor -a claude-code`；验证时检查 CLI list 与目标目录，而不是只看一个路径。

## Migration Plan

1. 在本仓库新增 `skills/mxcat-commit/` 与根 README。
2. 切片合并：每刀只新增或改该刀文件，不提前填满后续 reference 正文。
3. 有 GitHub remote 后，把文档中的 `<owner>` 替换为真实 owner，并用 `npx skills add ... --list` 验证发现。
4. 回滚：删除 `skills/mxcat-commit/` 与根 README 即可；无运行时服务、无数据迁移。

## Open Questions

- GitHub 用户名或 org 是什么（只影响最后一刀安装命令里的 `<owner>`，不改变包结构或规格）。
