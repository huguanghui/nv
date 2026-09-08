return {
  -- 括号彩虹染色：深层嵌套模板/多层括号肉眼可辨配对
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow = require("rainbow-delimiters")
      ---@type rainbow_delimiters#config
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy.global,
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        -- 禁用语言：纯文本/大输出窗口不启用
        disable = { "text", "toml", "json", "markdown" },
        priority = {
          [""] = 110,
          lua = 210,
        },
      }
    end,
  },
}
