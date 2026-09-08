# AGENTS.md

Neovim 配置仓库（LazyVim 框架），不是可运行的应用：验证方式是"加载配置/头less 启动"，没有构建和测试套件。

## 验证命令

```bash
# 语法检查单个文件（最快）
nvim --headless -u NONE -l /dev/stdin <<'EOF'
local chunk, err = loadfile("path/to/file.lua")
assert(chunk, err)
print("OK")
EOF

# lint（仅 selene；stylua 不在 PATH，格式化不可用）
selene lua/

# 完整配置加载验证（会启动插件系统，较慢）
nvim --headless "+lua require('overseer'); print('ok')" +qa
```

- 改动 `lazyvim.json`（extras）或 lockfile 后，用 `nvim --headless "+Lazy! clean" +qa` 清理孤儿插件。
- 没有测试；"测试"即 headless 加载 + `:checkhealth` 级别的功能探测。

## 结构与加载顺序

`init.lua` → `lua/config/lazy.lua`（bootstrap lazy.nvim → 导入 LazyVim → 导入 `lua/plugins/*.lua`）。

- `lua/plugins/`：每插件一个 flat 文件；标准功能优先用 `lazyvim.json` 的 `extras` 数组，不要手写已由 extra 提供的插件。
- AI 插件三选一由 `lua/config/options.lua` 的 `vim.g.ai_plugin`（当前 avante）控制，各文件用 `enabled = vim.g.ai_plugin == "xxx"` 门控；改默认值只动 options.lua。
- `lua/overseer/template/local.lua`：自定义任务模板。**必须用 generator 形式**；"返回列表"的模板文件在当前 overseer 版本会被静默忽略（load_template 直接返回 nil，仅打 deprecation 警告）。
- 文档在 `docs/`：`plan.md`（优化待办/已办）、`quick_use.md`（键位速查）、`cpp_dev.md`。改键位/行为后同步对应文档，`plan.md` 是工作台账。

## 仓库特有约定

- 所有注释用中文；StyLua 风格：2 空格、120 列、无分号；selene `std="vim"`。
- `lua/plugins/avante.lua` 启动时读 `.env`（gitignored，存 API key）——绝不能提交或把密钥写进其他文件。
- which-key 图标等多字节字符在重写文件时容易丢：git diff 验证字节，必要时用 `"\238\128\158"` 转义序列表示。
- 插件计数等数字（文档中写死的"62 插件/24 extras"）会漂移——编辑前用 `lazy-lock.json` / `lazyvim.json` 实数。
- 键位冲突排查：`nvim --headless "+verbose map <leader>xx"`；本仓库历史上多次因 extras 与本地插件同前缀撞键（现已修复 `<leader>t`/`<leader>C`/`<leader>i` 组），新增插件键位前先查。
- CLAUDE.md 仅是指向本文的转发文件，唯一指令来源是本文档。
