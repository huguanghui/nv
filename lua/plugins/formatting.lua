return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      aspvbs = { "djlint" }, -- 将 prettier 替换为 djlint
    },
    formatters = {
      djlint = {
        -- 可以根据需要添加参数，比如保留空格等
        prepend_args = { "--indent", "2" },
      },
    },
  },
}
