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
      },
    },
  },
}
