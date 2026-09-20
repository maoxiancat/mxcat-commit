# mxcat-commit

公开的 GitHub 技能源：提供 `mxcat-commit`，用 cz-emoji shortcode 生成提交信息，可通过 `npx skills` 安装到 Cursor、Claude Code 等 Agent。

源仓库：https://github.com/maoxiancat/mxcat-commit

## 安装

项目级（当前仓库）：

```bash
npx -y skills add maoxiancat/mxcat-commit --skill mxcat-commit
```

全局：

```bash
npx -y skills add maoxiancat/mxcat-commit --skill mxcat-commit -g
```

仅安装到 Cursor 和 Claude Code：

```bash
npx -y skills add maoxiancat/mxcat-commit --skill mxcat-commit -a cursor -a claude-code
```

## 验证发现

列出源里的技能（应出现 `mxcat-commit`，且不要安装）：

```bash
npx -y skills add maoxiancat/mxcat-commit --list
```

本仓库作为本地路径时也可以列出：

```bash
npx -y skills add /path/to/mxcat-commit --list
```
