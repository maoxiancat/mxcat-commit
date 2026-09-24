# 更新文档

## 1.4.2（2026-09-24）

- :bug: (mxcat-commit) 同一路径的两种写法、`--hunks` 旁路的已暂存文件，以及子目录中的换入，都只提交选中内容，未暂存改动留在工作区
- :bug: (mxcat-commit) 部分暂存时 `--add` 只提交 index 里已有的一截，未暂存改动留在工作区；已暂存的改名可以 `--add` 旧路径和新路径

## 1.4.1（2026-09-24）

- :bug: (mxcat-commit) 没有创建 commit 时把 index 放回调用前，已创建的 commit 仍不 reset
- :bug: (mxcat-commit) 按 hunk 或只提交已暂存内容时，符号链接和可执行位写入 commit，未纳入的改动留在工作区

## 1.4.0（2026-09-23）

- :sparkles: (mxcat-commit) 同一文件可按各自的改动分属多条 commit，未纳入的部分留在工作区

## 1.3.1（2026-09-23）

- :bug: (mxcat-commit) 标题与正文粘连、行首空白的禁止页脚和并列 scope 会在写入 commit 之前被拒绝
- :bug: (mxcat-commit) 同一文件的不同路径写法不再在提交后误报；目录和未改动路径在创建 commit 之前停止

## 1.3.0（2026-09-23）

- :sparkles: (mxcat-commit) Windows PowerShell 改用 commit_one.ps1 提交，sh 环境仍用 commit_one
- :bug: (mxcat-commit) 每条 commit 改经 commit_one 创建，不合规消息在写入前拒绝，并始终只提交给出的路径

## 1.2.1（2026-09-23）

- :sparkles: (mxcat-commit) 常用类型短表补上界面、代码格式、安全修复与添加依赖；`:wrench:` 只表示配置，依赖升级、降级、移除或锁版本，只改文案，以及 CI、国际化，才读完整表
- :bug: (mxcat-commit) 提交消息改为从本次命令的标准输入读入，不再写入固定临时路径

## 1.2.0（2026-09-22）

- :boom: (mxcat-commit) 预览后确认改为独立的「提交」（「好的，提交吧」「可以提交」算批准），点名子集当场做，改字可同句提交；固定收尾缩短为「尚未提交。回复「提交」或「提交并 push」」
- :sparkles: (mxcat-commit) 预览时提醒从未进过仓库的密钥与个人信息，skills/二进制默认与业务拆条
- :sparkles: (mxcat-commit) scope 按主语选一个小写英文短词，自检拒绝括号内空白
- :bug: (mxcat-commit) description 改为分析整棵未提交工作树并默认分批，不再只看 staged
- :bug: (mxcat-commit) 提交用 `--only` 锁预览路径，并用 `git show` 对照文件集合
- :bug: (mxcat-commit) 安装与验证改指向本技能目录 README，避免装进业务仓库后读到项目根 README
- :bug: (mxcat-commit) git 命令改按用途分族授权，自检与回执的只读查询不再被开头四件套挡住
- :bug: (mxcat-commit) 空行自检改为可判定，有第二段内容时要求 `%b` 非空
- :memo: (mxcat-commit) 成功回执字段组改用 Markdown 列表换行

## 1.1.2（2026-09-20）

- :sparkles: (mxcat-commit) 预览解释改动部分须写可跳转的仓库相对路径

## 1.1.1（2026-09-20）

- :memo: (mxcat-commit) push 成功回执去掉 `远程：` 行，保留 `分支：` 与 `仓库地址：`
- :bug: (mxcat-commit) 明确首轮「提交并 push」仍须先出预览，避免与收尾确认语混淆而跳过门禁

## 1.1.0（2026-09-20）

- :boom: 确认改为按本轮是否已出预览判定；预览后回复「提交」「确认提交」「帮我提交」或「提交并 push」才执行，不再把 lgtm / 就这样当作确认，也不再因「直接提交」跳过预览
- :sparkles: 预览卡后必须原样输出固定收尾；支持不要提交某条且文件留在工作区；全部 commit 成功后可一次 push
- :sparkles: 预览条目标题改为 `## commit N`（丢掉后保留原号）；提交与 push 成功后按模板回执（字段组内用 `<br>` 换行、不要空行），提交后再说 push 也可以推

## 1.0.0（2026-09-20）

- :sparkles: 默认按逻辑分批提交整棵工作树，标题用 cz-emoji shortcode 且必写 `(scope)`，确认前出示预览卡
