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

require("which-key").add({
  mode = {"n", "v"},
  { "<leader>a", group = "Avante", icon = " " },
})
