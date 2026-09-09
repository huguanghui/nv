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
  { "<leader>a", group = "AI", icon = "\238\128\158 " },
  { "<leader>m", group = "Misc", icon = "\239\160\181 " },
})
