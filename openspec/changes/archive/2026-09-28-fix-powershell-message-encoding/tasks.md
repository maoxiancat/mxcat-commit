## 1. 读入

- [x] 1.1 在 `scripts/validate.ps1` 的 `Read-CommitMessage` 中：管道里已有字符串时直接使用（一项原样返回，多于一项时用换行接上并在末尾补一个换行）；管道为空且标准输入被重定向时，再用 `OpenStandardInput()` 和无 BOM 的 UTF-8 读完。不设置 `[Console]::InputEncoding`，也不读 `[Console]::In`
- [x] 1.2 `scripts/commit_one.ps1` 继续点源 `validate.ps1` 后调用该函数。点源路径仍然只做 `Test-CommitMessage`，不另读一次标准输入

## 2. 调用

- [x] 2.1 `references/single-commit.md` 与 `references/batch-commit.md` 的 PowerShell 示例改为同一次进程内的三条语句：`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force`，把整段说明（含空行）按 UTF-8 做成 Base64 后解码成一个字符串，再管道给 `scripts/commit_one.ps1`。命令正文只含 ASCII。删掉管道前的 `$OutputEncoding` 赋值，不再使用第二个 `powershell -NoProfile -File`
- [x] 2.2 两份 guide 里说明这次调用方式的正文与示例一致。batch 的每条 commit 各自编码、各自管道。shell 的 `printf | scripts/commit_one` 保持不动

## 3. 码点对照

- [x] 3.1 在两份 guide 的 PowerShell 提交后自检中写明：入口返回 0 后，同一进程把 `[Console]::OutputEncoding` 设为无 BOM 的 UTF-8，用 `git -c i18n.logOutputEncoding=utf-8 log -1 --format=%B` 取出说明，把码点打成四位十六进制。两侧各去掉末尾一个换行后，与本次生成的文字对照。不一致则停止，不写成功回执，不 amend
- [x] 3.2 对照说明写上：「增加」是 `589E 52A0`，其 UTF-8 按 GBK 误读得到的「澧炲姞」是 `6FA7 70B2 59DE`。代码页 936 的屏幕显示不得代替码点。shell 的自检不增加这一段

## 4. 文档

- [x] 4.1 在 `skills/mxcat-commit/CHANGELOG.md` 顶部按现有条目格式记下：Windows PowerShell 在同一次进程内用 ASCII 命令送入说明，简体中文原样进入 commit，提交后再用码点对照
