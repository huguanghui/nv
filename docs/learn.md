# LazyVim配置

## 简介

LazyVim 采用 “starter template + 层级覆盖” 的设计哲学

lua/config/ 强制加载顺序 options -> keymaps -> autocmds -> lazy

options 设置vim.opt(leader, clipboard, number, tab)
keymaps 定义全局和插件快捷键
autocmds 颜色方案切换,filetype特定设置
lazy.lua setup

## TODO

- [x] tasks任务

## typescript开发环境搭建

### 启用TepeScript支持

lang.typescript（必须）
linting.eslint（强烈推荐，用于 ESLint 诊断）
formatting.prettier（推荐，用于 Prettier 格式化）
lang.json（推荐，处理 tsconfig.json 等）
lang.tailwind（如果你用 Tailwind CSS）

### 自定义 LSP 服务器

```lua
-- LSP Server for TypeScript
-- 可选值: "vtsls" (默认，推荐) 或 "tsgo" (更新、更快)
vim.g.lazyvim_ts_lsp = "vtsls"
```

### 常用快捷键

```
<leader>cl → 显示 LSP 信息
<leader>ca → Code Action（重构、Organize Imports 等）
<leader>cr → 重命名
<leader>cd → 显示诊断
gd / gD → Go to Definition / Declaration
K → Hover 文档
<leader>cf → 格式化当前文件（Prettier）
<leader>co → Organize Imports（TypeScript 特有）
```

### 安装依赖

```bash
npm install --save-dev typescript @types/node eslint prettier eslint-config-prettier
# 如果是 React/Next.js
npm install --save-dev @types/react @types/react-dom
```
