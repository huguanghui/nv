return {
  {
    "Tardouse/translate.nvim",
    cmd = { "Translate" },
    keys = {
      { "<leader>tt", "<cmd>Translate<cr>", mode = { "n", "v" }, desc = "Translate" },
      { "<leader>te", "<cmd>TranslateToEN<cr>", mode = { "n", "v" }, desc = "Translate to EN" },
      { "<leader>tc", "<cmd>TranslateToCN<cr>", mode = { "n", "v" }, desc = "Translate to CN" },
    },
    opts = {
      backend = "google",           -- 或 "openai" / "deepseek" 等
      default_target_lang = "zh-CN",
      -- 如果用 LLM，再加 backends 配置
    },
  },
}
