# Neovim 插件清单

> 本文档列出当前配置加载的全部插件及其功能。
> 数据来源：`lazy-lock.json` 与 `lazy.core.config`（运行时实际 spec）。
> 统计（2026-09-28）：共 **63** 个插件，其中运行时启用 **61** 个，禁用 **2** 个（AI 插件门控）。
> 数量会随更新漂移，改文档前请用 `lazy-lock.json` 实数核对。

## 环境

- Neovim：0.13.0-dev
- 框架：LazyVim + lazy.nvim
- 启用方式：`lazyvim.json` 的 `extras` 数组 + `lua/plugins/*.lua` 本地覆盖

## AI 插件三选一

由 `lua/config/options.lua` 的 `vim.g.ai_plugin` 控制，当前为 `avante`：

| 插件 | 仓库 | 功能 | 状态 |
| --- | --- | --- | --- |
| avante.nvim | yetone/avante.nvim | AI 编程助手（Cursor 风格） | ✅ 启用 |
| opencode.nvim | nickjvandyke/opencode.nvim | opencode 集成 | ⛔ 禁用 |
| claudecode.nvim | coder/claudecode.nvim | Claude Code 集成 | ⛔ 禁用 |

---

## 1. 核心框架与基础库

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| lazy.nvim | folke/lazy.nvim | 插件管理器（安装/更新/加载），启动引导见 `lua/config/lazy.lua` |
| LazyVim | LazyVim/LazyVim | 配置发行版/框架，提供默认键位与插件集 |
| plenary.nvim | nvim-lua/plenary.nvim | Lua 工具库，多个插件的公共依赖 |
| nui.nvim | MunifTanjim/nui.nvim | UI 组件库，avante 依赖 |
| nvim-nio | nvim-neotest/nvim-nio | 异步 IO 库，neotest 依赖 |

## 2. AI 助手与补全源

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| copilot.lua | zbirenbaum/copilot.lua | GitHub Copilot LSP 客户端 |
| blink-copilot | fang2hou/blink-copilot | Copilot 的 blink.cmp 补全源 |
| blink-cmp-avante | Kaiser-Yang/blink-cmp-avante | avante 的 blink.cmp 补全源 |

## 3. LSP / 补全 / 片段

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| nvim-lspconfig | neovim/nvim-lspconfig | LSP 客户端默认配置 |
| mason.nvim | mason-org/mason.nvim | LSP/DAP/lint/formatter 安装器 |
| mason-lspconfig.nvim | mason-org/mason-lspconfig.nvim | mason 与 lspconfig 桥接 |
| mason-nvim-dap.nvim | jay-babu/mason-nvim-dap.nvim | mason 与 nvim-dap 桥接 |
| blink.cmp | saghen/blink.cmp | 补全引擎 |
| LuaSnip | L3MON4D3/LuaSnip | 代码片段引擎 |
| friendly-snippets | rafamadriz/friendly-snippets | 社区片段集合 |
| lazydev.nvim | folke/lazydev.nvim | 为 Neovim 配置开发提供 Lua LSP 增强 |
| SchemaStore.nvim | b0o/SchemaStore.nvim | JSON/YAML schema 补全 |
| clangd_extensions.nvim | p00f/clangd_extensions.nvim | clangd 增强（内存用量、类型层级等） |
| inc-rename.nvim | smjonas/inc-rename.nvim | 带实时预览的增量重命名 |
| neogen | danymat/neogen | 生成注释/文档骨架 |

## 4. Treesitter

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| nvim-treesitter | nvim-treesitter/nvim-treesitter | 语法高亮与增量解析 |
| nvim-treesitter-textobjects | nvim-treesitter/nvim-treesitter-textobjects | 基于 treesitter 的文本对象与跳转 |
| nvim-ts-autotag | windwp/nvim-ts-autotag | HTML/JSX 标签自动闭合与重命名 |

## 5. 编辑增强

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| mini.ai | nvim-mini/mini.ai | 增强 `a`/`i` 文本对象 |
| mini.pairs | nvim-mini/mini.pairs | 自动括号/引号配对 |
| mini.icons | nvim-mini/mini.icons | 文件类型图标 |
| flash.nvim | folke/flash.nvim | 快速跳转/搜索标签 |
| rainbow-delimiters.nvim | HiPhish/rainbow-delimiters.nvim | 括号彩虹染色，便于配对深层嵌套 |
| grug-far.nvim | MagicDuck/grug-far.nvim | 全局查找替换（类 ripgrep + 编辑） |
| yanky.nvim | gbprod/yanky.nvim | 剪贴板历史与 yank 增强 |
| todo-comments.nvim | folke/todo-comments.nvim | TODO/FIXME 等高亮与检索 |
| ts-comments.nvim | folke/ts-comments.nvim | 基于 treesitter 的注释插入 |
| translate.nvim | Tardouse/translate.nvim | 翻译（`<leader>i` 组） |
| outline.nvim | hedyhli/outline.nvim | 符号大纲侧栏 |
| persistence.nvim | folke/persistence.nvim | 会话保存/恢复 |

## 6. UI / 外观

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| bufferline.nvim | akinsho/bufferline.nvim | buffer 标签栏 |
| lualine.nvim | nvim-lualine/lualine.nvim | 状态栏 |
| noice.nvim | folke/noice.nvim | 消息、命令行、通知 UI |
| snacks.nvim | folke/snacks.nvim | 多功能套件（picker/terminal/notify/dashboard 等） |
| trouble.nvim | folke/trouble.nvim | 诊断/引用/符号列表 |
| which-key.nvim | folke/which-key.nvim | 键位提示面板 |
| tokyonight.nvim | folke/tokyonight.nvim | 主题（LazyVim 默认） |
| catppuccin | catppuccin/nvim | 主题 |

## 7. 文件管理 / 会话

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| neo-tree.nvim | nvim-neo-tree/neo-tree.nvim | 文件树侧栏（`<leader>e`） |
| yazi.nvim | mikavilpas/yazi.nvim | 集成 yazi 终端文件管理器（`<leader>y`） |

## 8. Git

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| gitsigns.nvim | lewis6991/gitsigns.nvim | 行内 git 标记、暂存、diff、blame |

## 9. 任务 / 调试 / 测试

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| overseer.nvim | stevearc/overseer.nvim | 任务运行器（自定义模板见 `lua/overseer/`） |
| nvim-dap | mfussenegger/nvim-dap | 调试适配器协议客户端 |
| nvim-dap-ui | rcarriga/nvim-dap-ui | 调试界面 |
| nvim-dap-virtual-text | theHamsta/nvim-dap-virtual-text | 内联显示变量值 |
| nvim-dap-go | leoluz/nvim-dap-go | Go 调试配置 |
| neotest | nvim-neotest/neotest | 测试运行框架 |
| neotest-golang | fredrikaverpil/neotest-golang | Go 测试适配器 |
| nvim-lint | mfussenegger/nvim-lint | Lint 框架 |
| conform.nvim | stevearc/conform.nvim | 格式化框架 |

## 10. 语言支持

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| rustaceanvim | mrcjkb/rustaceanvim | Rust 一站式支持 |
| crates.nvim | Saecki/crates.nvim | Cargo.toml 依赖版本提示 |
| cmake-tools.nvim | Civitasv/cmake-tools.nvim | CMake 构建/运行/调试（`<leader>C` 组） |

## 11. Markdown / 文档

| 插件 | 仓库 | 功能 |
| --- | --- | --- |
| markdown-preview.nvim | iamcco/markdown-preview.nvim | 浏览器实时预览（固定 8113 端口，适配 SSH+tmux） |
| render-markdown.nvim | MeanderingProgrammer/render-markdown.nvim | 在编辑器内渲染 Markdown（也用于 Avante 窗口） |

---

## 本地定制（`lua/plugins/*.lua`）

以下插件在本仓库有自定义配置，行为与上游默认不同：

| 文件 | 插件 | 定制要点 |
| --- | --- | --- |
| `avante.lua` | avante.nvim | 启动读 `.env`；DeepSeek provider；自定义 system_prompt（强制 `str_replace`）；MCP 集成；自定义键位 |
| `neo-tree.lua` | neo-tree.nvim | `y` 复制文件名；`P` 复制 git 相对路径的 `@path` 引用 |
| `markdown-preview.lua` | markdown-preview.nvim | 固定 8113 端口、预览地址打印、复用同一预览页、启动前清理占用端口的旧服务 |
| `cmake-tools.lua` | cmake-tools.nvim | 强制使用 CMakePresets；runner/executor 走 overseer；`<leader>C` 组键位 |
| `formatting.lua` | conform.nvim | aspvbs 用 djlint、cmake 用 cmake_format |
| `lualine.lua` | lualine.nvim | 自定义模式图标与显示条件 |
| `noice.lua` | noice.nvim | 过滤 written/yanked/搜索边界等琐碎消息；命令行居中弹窗 |
| `rainbow-delimiters.lua` | rainbow-delimiters.nvim | 全局策略；禁用 text/toml/json/markdown |
| `translate.lua` | translate.nvim | `<leader>i` 组键位；Google 后端 |
| `wk.lua` | which-key.nvim | 扩展图标匹配规则 |
| `yazi.lua` | yazi.nvim | `<leader>y` / `<leader>cw` / `<c-up>` 键位 |
| `bufferline.lua` | bufferline.nvim | hover 显示关闭按钮；右上角主题切换/退出按钮 |
| `opencode.lua` | opencode.nvim | AI 门控（`ai_plugin=="opencode"`）；snacks.terminal 启动服务 |
| `claudecode.lua` | claudecode.nvim | AI 门控（`ai_plugin=="claude"`）；diff 接受/拒绝键位 |

## 维护提示

- **新增/删除插件**：优先改 `lazyvim.json` 的 `extras`；确需单独配置时在 `lua/plugins/` 新建 flat 文件。
- **数量核对**：`grep -c '"' lazy-lock.json` 或 `wc -l lazy-lock.json`（含首尾括号需减 1）。
- **清理孤儿插件**：`nvim --headless "+Lazy! clean" +qa`。
- **更新后**：`lazy-lock.json` 会变更，记得提交；涉及键位/行为变化时同步 `quick_use.md`。
