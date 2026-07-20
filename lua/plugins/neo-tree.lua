return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["y"] = function(state)
          local node = state.tree:get_node()
          local filename = node.name
          vim.fn.setreg('+', filename)
          vim.notify("Copied filename: " .. filename, vim.log.levels.INFO)
        end,
        -- 复制文件的 @path 引用（用于 AI 工具）
        ["P"] = function(state)
          local node = state.tree:get_node()
          if node.type ~= "file" then
            vim.notify("只能复制文件的路径引用", vim.log.levels.WARN)
            return
          end
          local full_path = node:get_id()
          local utils = require("config.utils")
          local rel_path = utils.get_git_rel_path(full_path) or full_path
          local ref = "@" .. rel_path
          vim.fn.setreg("+", ref)
          vim.notify("已复制: " .. ref, vim.log.levels.INFO)
        end,
      },
    },
  },
}
