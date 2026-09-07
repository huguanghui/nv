# 配置优化计划（plan.md）

> 更新于 2026-09-08，基于本轮配置梳理。已处理项均已验证（语法检查 + nvim 启动/模板加载无报错）。

## ✅ 已处理

| # | 事项 | 文件 | 说明 |
|---|---|---|---|
| 1 | 整理快捷键文档 | `quick_use.md` | 按 使用频率/技巧 分八节；含易混淆备忘 |
| 2 | `<leader>tt` 键位冲突（翻译 vs 测试） | `lua/plugins/translate.lua` | 翻译迁至 `<leader>ii/ie/ic`（i18n 组），`<leader>t` 归还 test.core |
| 3 | `X` 强删 buffer 丢代码风险 | `lua/config/keymaps.lua` | `:bdelete!` → `Snacks.bufdelete()`，未保存时提示而非丢弃 |
| 4 | `<leader>mc` 重复实现 git 路径逻辑 | `lua/config/keymaps.lua` | 复用 `utils.get_git_rel_path()`，含 cwd 回退 |
| 5 | avante copilot 死代码分支 | `lua/plugins/avante.lua` | 删除 `auto_suggestions_provider` 残留逻辑（`auto_suggestions=false` 下不生效） |
| 6 | 双搜索后端冗余（fzf + snacks_picker） | `lazyvim.json` | 移除 fzf extra，搜索统一 snacks picker |
| 7 | 文档同步 | `quick_use.md` | 键位表、冲突备忘节随上述修改更新 |
| 8 | `<leader>cd` 冲突：CMake Debug 覆盖 Line Diagnostics | `lua/plugins/cmake-tools.lua` | CMake 组整体换大写前缀 `<leader>C*`，`<leader>cd` 归还 LazyVim 诊断 |
| 9 | overseer 与 asynctasks 职责重叠 | `lua/plugins/asynctask.lua`（已删）/ `tasks.ini`（已删） | 选定方案 B：任务运行统一 overseer。新增 `lua/overseer/template/local.lua`（generator 形式实现 `file-run`：按 filetype 选解释器，python/lua/node/tsx/bash/go/ruby/perl；可执行文件直接运行；错误输出自动开 quickfix）。`Lazy clean` 移除 asynctasks.vim 与 telescope-asynctasks.nvim。注意：当前版本 overseer 已废弃"返回列表"的模板文件写法，新增模板请用 generator 形式 |
| 10 | CLAUDE.md 目录结构同步 | `CLAUDE.md` | 移除 asynctask.lua / tasks.ini 引用，新增 overseer 模板路径（AI 默认值与分支状态仍待更新，见待处理 #2） |
| 11 | `vim.opt.jumpoptions = "view"` | `lua/config/options.lua` | 已配置并验证生效：`<C-o>` 跳回时恢复视口位置 |
| 12 | CLAUDE.md 内容补全 | `CLAUDE.md` | 默认 AI 改为 avante；插件计数 63→62、extras 27→24；补 translate/yazi 插件项、overseer 任务运行一节（含"列表写法已废弃"提醒）；分支状态节更新为本轮优化摘要 |
| 13 | `keymaps.lua` 冗余 `opts` 包装 | `lua/config/keymaps.lua` | 移除 `opts` 共享表与 `vim.tbl_extend` 包装，改为每键 `{ silent = true, desc = ... }` 直写（附 desc）；顺带清理未使用的 snacks 局部变量；which-key 图标改用转义序列防止字符丢失 |

## ⏳ 待处理

（无 —— 本轮梳理的全部事项均已处理完毕）

## 🔜 可选后续（操作流，需练习适应）

- [ ] flash 跳转：`s` + 两字符跳任意位置，替代数字/相对行号移动
- [ ] 项目级替换走 grug-far（`<leader>sr`），替代 grep+sed 流
- [ ] yanky 循环粘贴：`p` 后 `<C-n>`/`<C-p>` 回溯寄存器，配合 `;p`
- [ ] Git 逐 hunk 暂存流：`]h`/`[h` + `<leader>ghs`，大改动拆 commit
- [ ] CMake 日常循环：`Cb` → `]d` 跳错 → `Cd`（debug）；考虑给 build 加 `-j` 并行
- [ ] AI diff 审查纪律：`]x`/`[x` 逐块 `ct` 采纳，避免 `ca` 全收
- [ ] 任务运行新入口：`<leader>oo` 搜任务、`<leader>ow` 任务列表（侧栏 `<CR>` 重启、`<C-q>` 转 quickfix、`p` 预览）

## 📌 备忘

- `lazy-lock.json` 的 diff 中包含本次 clean 移除 asynctasks 的变更（另含会话前的未提交更改）
- 键位冲突通用排查：`:verbose map <leader>xx`
- 搜索高亮清除：`<esc>`（LazyVim 默认）
