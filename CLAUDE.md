# Neovim 配置项目

基于 **LazyVim** 的高度定制化 Neovim 配置，侧重 AI 辅助开发。

## 目录结构

```
nvim/
├── init.lua              # 入口：require("config.lazy")
├── lua/
│   ├── config/           # 核心配置模块
│   │   ├── lazy.lua      # lazy.nvim 启动引导 + LazyVim 导入
│   │   ├── options.lua   # 全局选项（autoformat、colorscheme、clipboard）
│   │   ├── keymaps.lua   # 全局快捷键
│   │   ├── autocmds.lua  # 自动命令
│   │   ├── utils.lua     # 工具函数（foldtext、toggle_theme、MCP检查）
│   │   └── prompts.lua   # AI 系统提示词（Avante 用）
│   └── plugins/          # 插件配置（每插件一个文件，flat 结构）
│       ├── avante.lua
│       ├── claudecode.lua
│       ├── opencode.lua
│       ├── lualine.lua
│       ├── bufferline.lua
│       ├── noice.lua
│       ├── neo-tree.lua
│       ├── wk.lua
│       ├── cmake-tools.lua
│       ├── translate.lua
│       ├── yazi.lua
│       └── formatting.lua
├── snippets/             # VS Code 风格代码片段（C/C++）
├── lazy-lock.json        # 插件版本锁定文件（62 个插件）
├── lazyvim.json          # LazyVim extras 清单（24 个 extras）
├── stylua.toml           # Lua 格式化配置
├── selene.toml           # Lua lint 配置
├── .neoconf.json         # neoconf 配置
├── lua/overseer/template/local.lua  # overseer 自定义任务模板（任务运行）
├── plan.md               # 配置优化计划（待办/已完成）
└── quick_use.md          # 快捷键速查表
```

## 核心约定

### 插件管理模式
- **LazyVim extras 优先**：通过 `lazyvim.json` 的 `extras` 数组引入标准 LazyVim extras
- **用户覆盖**：`lua/plugins/` 下每插件一个 `.lua` 文件，flat 结构无子目录
- **启动顺序**：`init.lua` → `config/lazy.lua`（bootstrap lazy.nvim → import LazyVim → import plugins/ 目录）
- **禁用默认插件**：`gzip`、`tarPlugin`、`tohtml`、`tutor`、`zipPlugin` 已被禁用

### 代码风格
- **注释**：所有注释使用中文
- **格式化**：StyLua，2 空格缩进，120 列宽，无分号
- **Lint**：Selene，std="vim"
- **变量命名**：Neovim 全局变量用 `vim.g.xxx`、`vim.opt.xxx`

### AI 插件切换机制
项目同时配置了三种 AI 插件，通过 `vim.g.ai_plugin` 全局变量切换：
- `"avante"` — 启用 avante.nvim（**当前默认**，`options.lua` 中设置）
- `"claude"` — 启用 claudecode.nvim
- `"opencode"` — 启用 opencode.nvim

各插件在 `lua/plugins/*.lua` 中通过 `enabled = vim.g.ai_plugin == "xxx"` 控制启用。
AI 提供商由 `vim.g.ai_provider` 控制（deepseek / copilot）。

### 主题
- 通过 `utils.toggle_theme()` 在 `catppuccin-mocha` 和 `tokyonight-moon` 之间切换
- 默认 dark 背景，启用 termguicolors

## 常用任务

### 添加新插件
1. 在 `lua/plugins/` 创建 `<plugin-name>.lua`
2. 使用 lazy.nvim spec 格式：`return { "author/plugin", opts = {}, keys = {} }`
3. 若是 LazyVim 已有 extra，优先在 `lazyvim.json` 中启用

### 修改快捷键
- 全局快捷键 → `lua/config/keymaps.lua`
- 插件快捷键 → 在对应 `lua/plugins/<name>.lua` 的 `keys` 字段

### 修改全局选项
- 编辑 `lua/config/options.lua`

### 任务运行（overseer）
- 自定义任务模板 → `lua/overseer/template/local.lua`（generator 形式，勿用"返回列表"写法，已废弃）
- 入口：`<leader>oo` 搜任务运行，`<leader>ow` 任务列表

### 更新插件版本
- 运行 `:Lazy update` 自动更新 `lazy-lock.json`
- 手动编辑 `lazy-lock.json` 锁定特定版本

### 调试
- 使用 `:Lazy` 查看插件状态（`Lazy clean` 清理 lock 中的孤儿插件）
- 使用 `:checkhealth` 检查 LSP/DAP/Mason 状态
- 查看 `:messages` 获取错误信息

## 当前分支状态

- **分支**: main
- **2026-09-08 优化批次**: 键位冲突修复（翻译 `<leader>i` 组、CMake `<leader>C` 组）、`X` 改安全删除、asynctasks 迁 overseer、移除 fzf extra —— 详见 `plan.md`
- **工作区**: 存在未提交更改（keymaps/options/avante/cmake-tools/translate、lazyvim.json、lazy-lock.json 及新增文档），提交前先 `git status` 确认
