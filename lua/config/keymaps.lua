local map = vim.keymap.set

-- escape：jk 退出插入模式并保存
map("i", "jk", "<ESC>:w<CR>", { silent = true })

-- buffers
map("n", "X", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "L", "<cmd>BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
map("n", "H", "<cmd>BufferLineCyclePrev<CR>", { silent = true, desc = "Prev buffer" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", ";p", '"0p', { silent = true, desc = "Paste from yank register" })
map("n", ";c", '"_c', { silent = true, desc = "Change to blackhole register" })
map("n", ";d", '"_d', { silent = true, desc = "Delete to blackhole register" })

-- 可视模式复制文件范围引用 (@path:start-end)
-- 用于粘贴到 Claude Code 等 AI 工具中引用代码块
map("v", "<leader>mc", function()
  local path = vim.fn.expand("%")
  if path == "" then
    vim.notify("没有文件名", vim.log.levels.WARN)
    return
  end
  -- 使用 line("v")/line(".") 获取当前可视选择范围
  -- ('< 和 '> 在 visual 回调中还未更新)
  local v_start = vim.fn.line("v")
  local v_end = vim.fn.line(".")
  local start_line, end_line = math.min(v_start, v_end), math.max(v_start, v_end)

  -- 转换为 git 仓库相对路径（复用 utils，含 cwd 回退逻辑）
  local utils = require("config.utils")
  path = utils.get_git_rel_path(vim.fn.expand("%:p")) or path

  local range_str = "@" .. path .. ":" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", range_str)
  vim.notify("已复制: " .. range_str, vim.log.levels.INFO)
end, { desc = "Copy range ref" })

-- 普通模式复制文件路径引用 (@path)
-- 用于粘贴到 Claude Code 等 AI 工具中引用整个文件
map("n", "<leader>mp", function()
  local utils = require("config.utils")
  local full_path, is_dir = utils.get_context_path()
  if not full_path then
    vim.notify("没有文件名", vim.log.levels.WARN)
    return
  end
  local path = utils.get_git_rel_path(full_path) or full_path
  -- 目录节点补尾斜杠，与 neo-tree 内置 P 映射行为一致
  if is_dir and not path:match("/$") then
    path = path .. "/"
  end
  local ref = "@" .. path
  vim.fn.setreg("+", ref)
  vim.notify("已复制: " .. ref, vim.log.levels.INFO)
end, { desc = "Copy file path ref" })

require("which-key").add({
  mode = { "n", "v" },
  -- Nerd Fonts v3 码点：cod-robot U+EC20 / cod-tools U+EB6D
  -- 旧码点 U+E01E、U+F835 在 NF v3 中已移除，会导致 which-key 图标显示为方框
  { "<leader>a", group = "AI", icon = "\238\176\160 " },
  { "<leader>m", group = "Misc", icon = "\238\173\173 " },
  -- AI 子项：显式指定图标，避免全部继承 <leader>a 的组图标
  { "<leader>ac", icon = "\238\171\135 " }, -- nf-cod-comment_discussion
  { "<leader>ae", icon = "\238\169\179 " }, -- nf-cod-edit
  { "<leader>ah", icon = "\238\170\130 " }, -- nf-cod-history
  { "<leader>al", icon = "\238\170\191 " }, -- nf-cod-clear_all
  { "<leader>an", icon = "\238\169\160 " }, -- nf-cod-add
  { "<leader>ap", icon = "\238\174\162 " }, -- nf-cod-server_process
  { "<leader>as", icon = "\238\171\151 " }, -- nf-cod-debug_stop
  -- 顶层映射：Keywordprg（LazyVim 的 <leader>K）
  { "<leader>K", icon = "\238\170\164 " }, -- nf-cod-book
})
