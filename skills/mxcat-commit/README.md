# mxcat-commit

生成 cz-emoji shortcode 风格的提交信息。技能包入口是同目录的 `SKILL.md`。

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

```bash
npx -y skills add maoxiancat/mxcat-commit --list
```

输出中应出现 `mxcat-commit`。
