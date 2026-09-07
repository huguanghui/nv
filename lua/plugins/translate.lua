return {
  {
    "Tardouse/translate.nvim",
    cmd = { "Translate" },
    -- <leader>i 组（i18n），避免与 test.core 的 <leader>t 组冲突
    keys = {
      { "<leader>ii", "<cmd>Translate<cr>", mode = { "n", "v" }, desc = "Translate" },
      { "<leader>ie", "<cmd>TranslateToEN<cr>", mode = { "n", "v" }, desc = "Translate to EN" },
      { "<leader>ic", "<cmd>TranslateToCN<cr>", mode = { "n", "v" }, desc = "Translate to CN" },
    },
    opts = {
      backend = "google",           -- 或 "openai" / "deepseek" 等
      default_target_lang = "zh-CN",
      -- 如果用 LLM，再加 backends 配置
    },
  },
}
