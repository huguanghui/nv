local aucmd = vim.api.nvim_create_autocmd

-- Set relative line numbers in normal mode
aucmd({ "InsertEnter" }, {
  callback = function()
    local fname = vim.fn.bufname()
    if fname == "copilot-chat" or vim.bo.buftype == "nofile" then
      return
    end
    vim.opt_local.relativenumber = false
  end,
})

-- and absolute line numbers in insert mode
aucmd({ "InsertLeave" }, {
  callback = function()
    local fname = vim.fn.bufname()
    if fname == "copilot-chat" or vim.bo.buftype == "nofile" then
      return
    end
    vim.opt_local.relativenumber = true
  end,
})

-- Terminal
aucmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- Codelens
aucmd({ "BufEnter", "InsertLeave" }, {
  pattern = { "*.rs", "*.go" },
  callback = function()
    vim.lsp.codelens.refresh({ bufnr = 0 })
  end,
})

aucmd({ "BufEnter" }, {
  pattern = { "*.csv" },
  callback = function()
    vim.cmd("set noarabicshape")
  end,
})

aucmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    require("config.utils").set_terminal_keymaps()
  end,
})

vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
