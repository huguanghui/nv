LazyVim 采用 “starter template + 层级覆盖” 的设计哲学

lua/config/ 强制加载顺序 options -> keymaps -> autocmds -> lazy

options 设置vim.opt(leader, clipboard, number, tab)
keymaps 定义全局和插件快捷键
autocmds 颜色方案切换,filetype特定设置
lazy.lua  setup

## TODO

- [x] tasks任务
