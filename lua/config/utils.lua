local M = {}

local api = vim.api
local fn = vim.fn
local ts = vim.treesitter

function M.foldtext()
  local pos = vim.v.foldstart
  local line = api.nvim_buf_get_lines(0, pos - 1, pos, false)[1]

  local ft = vim.bo.filetype
  local lang = ts.language.get_lang(ft)
  if not lang then
    return fn.foldtext()
  end

  local parser = ts.get_parser(0, lang, { error = false })
  if not parser then
    return fn.foldtext()
  end

  local query = ts.query.get(parser:lang(), "highlights")
  if not query then
    return fn.foldtext()
  end

  local tree = parser:parse({ pos - 1, pos })[1]
  if not tree then
    return fn.foldtext()
  end

  local root = tree:root()
  if not root then
    return fn.foldtext()
  end

  local result = {}
  local line_pos = 0
  local prev_range = nil

  local fold_line_count = vim.v.foldend - vim.v.foldstart
  local fold_suffix = " {...} ( " .. fold_line_count .. " lines)"

  for id, node, _ in query:iter_captures(root, 0, pos - 1, pos) do
    local name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()

    if start_row ~= pos - 1 or end_row ~= pos - 1 then
      goto continue
    end

    if start_col > line_pos then
      table.insert(result, { line:sub(line_pos + 1, start_col), "Folded" })
    end

    line_pos = end_col

    local text = ts.get_node_text(node, 0)

    if prev_range and start_col == prev_range[1] and end_col == prev_range[2] then
      result[#result] = { text, "@" .. name }
    else
      table.insert(result, { text, "@" .. name })
    end

    prev_range = { start_col, end_col }

    ::continue::
  end

  table.insert(result, { fold_suffix, "Folded" })

  return result
end

function M.toggle_theme()
  if (vim.g.colors_name or ""):find("catppuccin") then
    vim.cmd.colorscheme("tokyonight-moon")
  else
    vim.cmd.colorscheme("catppuccin-mocha")
  end
end

function M.qftf(info)
  local items
  local ret = {}

  if info.quickfix == 1 then
    items = fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end

  local limit = 25
  local fname_fmt1 = "%-" .. limit .. "s"
  local fname_fmt2 = "…%." .. (limit - 1) .. "s"
  local valid_fmt = "%s |%5d:%-3d|%s %s"
  local invalid_fmt = "%s"
  local home_pattern = "^" .. vim.env.HOME

  -- use luajit table.new if available
  ret = table.new and table.new(info.end_idx - info.start_idx + 1, 0) or {}

  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local str

    if e.valid == 1 then
      local fname = ""
      if e.bufnr > 0 then
        fname = api.nvim_buf_get_name(e.bufnr)
        if fname == "" then
          fname = "[No Name]"
        else
          fname = fname:gsub(home_pattern, "~")
        end

        if #fname <= limit then
          fname = string.format(fname_fmt1, fname)
        else
          fname = string.format(fname_fmt2, fname:sub(1 - limit))
        end
      end

      local lnum = e.lnum > 99999 and "inf" or e.lnum
      local col = e.col > 999 and "inf" or e.col
      local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()

      str = string.format(valid_fmt, fname, lnum, col, qtype, e.text)
    else
      str = string.format(invalid_fmt, e.text)
    end

    ret[i - info.start_idx + 1] = str
  end

  return ret
end

M.set_terminal_keymaps = function()
  local map = vim.keymap.set
  local opts = { buffer = 0, noremap = true }

  map("t", "<esc>", [[<C-\><C-n>]], opts)
  map("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  map("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  map("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  map("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

M.kind_icons = {
  Array = "",
  Boolean = "󰨙",
  Class = "",
  Codeium = "󰘦",
  Color = "",
  Control = "",
  Collapsed = "",
  Constant = "󰏿",
  Constructor = "",
  Copilot = "",
  Enum = "ℰ",
  EnumMember = "",
  Event = "",
  Field = "󰜢",
  File = "󰈚",
  Folder = "",
  Function = "󰊕",
  Interface = " ",
  Implementation = "",
  Key = "",
  Keyword = "",
  Macro = " 󰁌 ",
  Method = "ƒ",
  Module = "",
  Namespace = "󰦮",
  Null = "",
  Number = "󰎠",
  Object = "",
  Operator = "",
  Package = "",
  Parameter = "",
  Property = "",
  Reference = "",
  Snippet = "", --" ",""," ","󱄽 "
  Spell = "󰓆",
  StaticMethod = "",
  String = "󰅳", -- " ","𝓐 " ," " ,"󰅳 "   
  Struct = "󰙅", -- "  "
  Supermaven = "",
  TabNine = "󰏚",
  Text = "󰉿",
  TypeAlias = "",
  TypeParameter = "",
  Unit = "󰑭",
  Value = "",
  Variable = "󰆦",
}

-- 获取相对于 git 仓库根目录的路径（用于 AI 工具的 @path 引用格式）
-- @param full_path 可选，完整路径；省略时使用当前 buffer 的路径
function M.get_git_rel_path(full_path)
  local path
  if full_path then
    path = full_path
  elseif vim.api.nvim_buf_get_name(0) ~= "" then
    path = vim.fn.expand("%:p")
  else
    return nil
  end

  if path == "" then
    return nil
  end

  -- 尝试转换为 git 仓库相对路径
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if git_root then
    local prefix = git_root:match("^(.+)/$") or git_root
    if path:sub(1, #prefix) == prefix then
      return path:sub(#prefix + 2)
    end
  end

  -- 回退：相对于当前工作目录
  local cwd = vim.fn.getcwd()
  local cwd_norm = cwd:match("^(.+)/$") or cwd
  if path:sub(1, #cwd_norm) == cwd_norm then
    return path:sub(#cwd_norm + 2)
  end

  return path
end

M.is_mcp_present = function()
  if vim.uv.fs_stat(vim.fn.expand("~/.mcpservers.json")) then
    return true
  end
  return false
end

M.is_online = function()
  if vim.env.NVIM_OFFLINE == "1" then
    return false
  end

  local host = "api.github.com"
  local is_online = false

  local ok, res = pcall(function()
    return vim.uv.getaddrinfo(host, nil, { socktype = "stream" })
  end)

  if ok and res and #res > 0 then
    is_online = true
  end

  return is_online
end

return M
