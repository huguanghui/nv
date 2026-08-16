-- 检测 LuaJIT FFI 能否解析指定的 C 符号
local function ffi_symbol_exists(cdef, name)
  return pcall(function()
    local ffi = require("ffi")
    ffi.cdef(cdef)
    local _ = ffi.C[name]
  end)
end

-- Neovim 0.13+ (neovim#39485) 将 search_match_lines / search_match_endcol
-- 移入 Search 结构体,flash.nvim 的 hacks.lua 仍通过 FFI 读取旧全局符号,
-- 按 s 搜索时会报 "undefined symbol: search_match_lines"。
-- 这里提供纯 Lua 兼容实现,仅在旧符号缺失时生效(不影响旧版 Neovim)。
local function apply_compat()
  local has_legacy =
    ffi_symbol_exists([[unsigned int search_match_lines; int search_match_endcol;]], "search_match_lines")
  if has_legacy then
    return
  end

  local Search = require("flash.search")
  local Pos = require("flash.search.pos")
  local Hacks = require("flash.hacks")

  -- 覆盖 Search:_next:显式 pattern 先定位匹配起点,再取匹配终点,
  -- 完全绕过依赖 FFI 全局变量的 Hacks.get_end_pos
  Search._next = function(self, flags)
    flags = flags or ""
    local ok, pos = pcall(vim.fn.searchpos, self.state.pattern.search, flags)
    if not ok or pos[1] == 0 then
      return
    end
    pos = Pos({ pos[1], pos[2] - 1 })
    -- 光标已位于匹配起点,用 "cen" 获取当前匹配终点(不移动光标)
    local ok_end, endpos = pcall(vim.fn.searchpos, self.state.pattern.search, "cen")
    local end_pos = ok_end and endpos[1] ~= 0 and Pos({ endpos[1], endpos[2] - 1 }) or pos
    return { win = self.win, pos = pos, end_pos = end_pos }
  end

  -- incsearch 状态的保存/恢复同样依赖这两个符号,缺失时 no-op
  -- (仅影响 / 增量搜索高亮的短暂保持,属外观问题,不影响功能)
  Hacks.save_incsearch_state = function() end
  Hacks.restore_incsearch_state = function() end
end

return {
  {
    "folke/flash.nvim",
    config = function(_, opts)
      require("flash").setup(opts)
      apply_compat()
    end,
  },
}
