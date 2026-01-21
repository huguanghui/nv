return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    -- 保留原有的 preset 和 icons 設定
    opts.preset = "classic"

    opts.icons = opts.icons or {}
    opts.icons.rules = opts.icons.rules or {}

    -- 原有 + 擴充的圖示規則
    local custom_rules = {
      -- 你原本的規則
      { pattern = "readability", icon = "󰊰 ", color = "blue" },
      { pattern = "optimize",    icon = " ", color = "green" },
      { pattern = "summarize",   icon = " ", color = "cyan" },
      { pattern = "explain",     icon = "󰘦 ", color = "orange" },
      { pattern = "fix",         icon = " ", color = "red" },
      { pattern = "tests",       icon = " ", color = "azure" },
      { pattern = "ask",         icon = "󱜺 ", color = "green" },
      { pattern = "refresh",     icon = " ", color = "yellow" },
      { pattern = "focus",       icon = "󰋱 ", color = "purple" },
      { pattern = "model",       icon = " ", color = "grey" },
      { pattern = "repo",        icon = " ", color = "cyan" },
      { pattern = "overseer",    icon = "󰑮 ", color = "cyan" },

      -- 可選擴充（可依需求保留或刪除）
      { pattern = "file",        icon = "󰈔 ", color = "blue" },
      { pattern = "buffer",      icon = " ", color = "magenta" },
      { pattern = "search",      icon = " ", color = "yellow" },
      { pattern = "git",         icon = "󰊢 ", color = "orange" },
      { pattern = "debug",       icon = " ", color = "red" },
      { pattern = "terminal",    icon = " ", color = "green" },
      { pattern = "lsp",         icon = " ", color = "cyan" },
      { pattern = "code",        icon = " ", color = "blue" },
      { pattern = "window",      icon = " ", color = "purple" },
      -- { pattern = "tab",      icon = "󰓩 ", color = "grey" },  -- 既然要隱藏 tab 就不加這個了
    }

    -- 合併規則（避免覆蓋原有）
    for _, rule in ipairs(custom_rules) do
      table.insert(opts.icons.rules, rule)
    end

    -- 隱藏 tabs 組（你提供的代碼）
    opts.spec = opts.spec or {}
    table.insert(opts.spec, {
      "<leader><tab>",
      hidden = true,  -- 完全不在 which-key 彈窗中顯示 tabs 組
    })

    return opts
  end,
}
