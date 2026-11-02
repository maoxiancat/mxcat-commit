# mxcat-changelog

按统一规范更新项目中的 CHANGELOG。技能包入口是同目录的 `SKILL.md`。

源仓库：https://github.com/maoxiancat/mxcat-changelog

## 安装

项目：

```bash
npx -y skills add maoxiancat/mxcat-changelog --skill mxcat-changelog
```

全局：

```bash
npx -y skills add maoxiancat/mxcat-changelog --skill mxcat-changelog -g
```

仅安装到 Cursor 和 Claude Code：

```bash
npx -y skills add maoxiancat/mxcat-changelog --skill mxcat-changelog -a cursor -a claude-code
```

## 验证

```bash
npx -y skills add maoxiancat/mxcat-changelog --list
```

输出中应出现 `mxcat-changelog`。
