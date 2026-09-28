## 1. 说明读入

- [x] 1.1 在 `scripts/validate.ps1` 增加 `Read-CommitMessage`：标准输入被重定向时，先用 `OpenStandardInput()` 和无 BOM 的 UTF-8 读完字节，不枚举 `$input`，也不再改 `[Console]::InputEncoding` 后读 `[Console]::In`；未重定向时使用 `$input` 里的 .NET 字符串
- [x] 1.2 `validate.ps1` 作为脚本执行时改走 `Read-CommitMessage`；`scripts/commit_one.ps1` 点源后调用同一函数，删掉自己的读入段
- [ ] 1.3 在 Windows PowerShell 5.1 上确认 `powershell -File` 启动时原始字节仍在标准输入。若宿主已按 OEM 代码页读完，按 design.md 把 guide 改成同一子进程内的 here-string，不再把消息字节交给第二个进程解码

## 2. hunk 与换入

- [x] 2.1 `Get-PatchPaths` 与 `Get-HunkTexts` 按换行拆开并保留空段，去掉 `` -split "`n", -1 ``
- [x] 2.2 换入普通文件时按 shell 版设置或清除可执行位；文件系统表达不了 `100755` 时再 `update-index --chmod=+x`。`core.filemode=true` 时不得把 `100755` 提交成 `100644`
- [x] 2.3 符号链接的创建和失败恢复共用不含 `-LiteralPath` 的调用；创建失败且未创建 commit 时，原路径仍是调用前的链接
- [x] 2.4 `git cat-file blob` 按字节写入临时文件，不再用 `Start-Process -RedirectStandardOutput` 做文本重定向

## 3. Windows 路径

- [x] 3.1 `Resolve-PhysicalDirectory` 在 Windows 上取目录最终路径并去掉 `\\?\` 前缀；非 Windows 仍用 `cd -P`。经目录符号链接进入仓库的绝对路径不得报「路径不在仓库内」

## 4. 文档

- [x] 4.1 `references/single-commit.md` 与 `references/batch-commit.md` 的 PowerShell 示例在管道之前把 `$OutputEncoding` 与 `[Console]::OutputEncoding` 设为无 BOM 的 UTF-8；若 1.3 改了调用形态，两处示例一起改
- [x] 4.2 在 `skills/mxcat-commit/CHANGELOG.md` 顶部按现有条目格式记下说明编码、hunk 换行、可执行位、符号链接恢复和 Windows 符号链接路径
