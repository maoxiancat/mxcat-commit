## 1. commit_one

- [x] 1.1 给 `scripts/commit_one` 增加 `--hunks <file>`。补丁必须是本次调用专属文件，不得读取 `/tmp/commit_msg.txt` 这类固定共享路径。消息仍只来自标准输入
- [x] 1.2 补丁中的已跟踪路径按部分提交：在从 HEAD 建起的临时 index 上应用补丁并读出 blob，备份工作区后换入，对其余路径照旧处理，再 `git commit --only --` 全部路径参数。`EXIT` 时恢复备份，包括 hook 失败和自检失败
- [x] 1.3 补丁不是这些路径上 `git diff HEAD` 的完整 hunk 子集、路径是二进制、是 rename 或 copy 且还要拆内容、或路径尚未进入 HEAD 时，在替换工作区与 `git commit` 之前非 0 退出，且不退回整文件提交
- [x] 1.4 不带 `--hunks`、不带 `--add`、路径仍有未暂存改动时：index 相对 HEAD 有差异则提交该 index blob 并恢复工作区；index 与 HEAD 相同则在 `git commit` 之前退出。带 `--add` 的整文件路径行为保持不变
- [x] 1.5 部分提交或 index blob 提交成功后，除现有路径集合对照外，核对该文件的 commit diff 等于本次 blob 相对父版本的 diff。不一致则非 0 退出，不 `reset`

## 2. commit_one.ps1

- [x] 2.1 `scripts/commit_one.ps1` 接受与 `commit_one` 相同的 `--hunks` 与 `--add`，部分提交、index blob、拒绝条件和 diff 自检的退出语义一致

## 3. 测试

- [x] 3.1 在 `skills/mxcat-commit/tests/check_scripts` 覆盖：同一文件两段 hunk，第一段 `--hunks` 后工作区字节不变且只含该段，第二段 `--add` 只含剩余 diff；同一次调用里其它整文件路径进入 commit，未列入的已暂存路径仍留在 index
- [x] 3.2 覆盖拒绝路径：补丁对不上当前 diff、二进制、未进入 HEAD 的新文件时不创建 commit，工作区字节不变
- [x] 3.3 覆盖只要暂存区：index 有改动且工作区还有更多时，commit diff 等于 index 相对 HEAD 的 diff，未暂存部分仍在；index 与 HEAD 相同时不创建 commit

## 4. 文档

- [x] 4.1 更新 `references/batch-commit.md`：同一路径出现在多条时，每条标明自己的 hunk；非最后一段使用 `--hunks`，最后一段只要剩余全部时用现有 `--add`。对不上 diff、二进制、rename 同时拆内容时停止，不退回整文件
- [x] 4.2 更新 `references/troubleshooting.md`：部分提交失败时工作区应已恢复；diff 对不上时 commit 已存在且不自动 reset。`single-commit.md` 不增加 `--hunks` 样例
- [x] 4.3 `SKILL.md` 最多用一句话指向入口的部分提交，不展开命令。用 changelog-content-writer 更新 `skills/mxcat-commit/CHANGELOG.md`，不改写已发布版本条目正文
