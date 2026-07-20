local map = vim.keymap.set
local term = require("snacks.terminal")
local lazygit = require("snacks.lazygit")
local opts = { noremap = true, silent = true }

-- escape
map("i", "jk", "<ESC>:w<CR>", opts)

-- buffers
map("n", "X", ":bdelete!<CR>", opts)
map("n", "L", ":BufferLineCycleNext<CR>", opts)
map("n", "H", ":BufferLineCyclePrev<CR>", opts)
map("n", "gl", vim.diagnostic.open_float, opts)
map("n", ";p", '"0p', opts)
map("n", ";c", '"_c', opts)
map("n", ";d", '"_d', opts)

-- 可视模式复制文件范围引用 (@path:start-end)
-- 用于粘贴到 Claude Code 等 AI 工具中引用代码块
map("v", "<leader>mc", function()
  local path = vim.fn.expand("%")
  if path == "" then
    vim.notify("没有文件名", vim.log.levels.WARN)
    return
  end
  -- 修正：使用 line("v")/line(".") 获取当前可视选择范围
  -- ('< 和 '> 在 visual 回调中还未更新)
  local v_start = vim.fn.line("v")
  local v_end = vim.fn.line(".")
  local start_line, end_line = math.min(v_start, v_end), math.max(v_start, v_end)

  -- 转换为 git 仓库相对路径
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if git_root then
    local full_path = vim.fn.expand("%:p")
    path = full_path:sub(#git_root + 2)
  end

  local range_str = "@" .. path .. ":" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", range_str)
  vim.notify("已复制: " .. range_str, vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "Copy range ref" }))

-- 普通模式复制文件路径引用 (@path)
-- 用于粘贴到 Claude Code 等 AI 工具中引用整个文件
map("n", "<leader>mp", function()
  local utils = require("config.utils")
  local path = utils.get_git_rel_path()
  if not path then
    vim.notify("没有文件名", vim.log.levels.WARN)
    return
  end
  local ref = "@" .. path
  vim.fn.setreg("+", ref)
  vim.notify("已复制: " .. ref, vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "Copy file path ref" }))

require("which-key").add({
  mode = { "n", "v" },
  { "<leader>a", group = "AI", icon = " " },
  { "<leader>m", group = "Misc", icon = " " },
})
