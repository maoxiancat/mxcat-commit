## 1. UTF-8 commit message

- [x] 1.1 在 `commit_one.ps1` 中，标准输入已重定向时于枚举 `$input` 之前按无 BOM UTF-8 读完原始字节，作为提交说明
- [x] 1.2 标准输入未重定向时仍使用 `$input` 中的字符串

## 2. Repository root encoding

- [x] 2.1 在第一次调用 Git 之前，把子进程的 `[Console]::OutputEncoding` 与 `$OutputEncoding` 设为无 BOM UTF-8
- [x] 2.2 用该解码结果作为后续 `git -C` 的仓库根，使路径中的非 ASCII 字符（如「杂」）得以保留

## 3. Fail closed

- [x] 3.1 解析仓库根后执行 `git -C` 探测，非零状态时在 `git add` 与 `git commit` 之前退出
- [x] 3.2 改名检测、`ls-files`、`ls-tree` 的 `git -C` 非零时退出，不再把空输出当成没有暂存信息

## 4. Skill examples

- [x] 4.1 `references/batch-commit.md` 的 PowerShell 示例在管道前设置无 BOM UTF-8 的 `$OutputEncoding`，并仍调用 `powershell -NoProfile -File commit_one.ps1`
- [x] 4.2 `references/single-commit.md` 的 PowerShell 示例做同样修改

## 5. Verification

- [x] 5.1 在临时仓库中，父会话设置 `$OutputEncoding` 后经子进程提交含「调整首页」的说明，确认 commit 对象里仍是这些汉字
- [x] 5.2 在路径含「杂」的仓库中确认 `git -C` 使用的根路径含「杂」，且故意失败的 `git -C` 不会创建 commit
- [x] 5.3 确认本变更没有 `reset`、`amend` 或 `push` 本地提交 `a0e0954`
