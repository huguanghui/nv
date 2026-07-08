return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  enabled = function()
    return vim.g.ai_plugin == "opencode"
  end,
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        -- 使用 snacks.terminal 启动 opencode 服务
        start = function()
          local snacks_ok, snacks = pcall(require, "snacks.terminal")
          if snacks_ok then
            snacks.open("opencode --port", {
              win = { position = "right", enter = false },
            })
          else
            vim.cmd("terminal opencode --port")
          end
        end,
      },
      events = {
        reload = true, -- 自动重载被 OpenCode 编辑的缓冲区
      },
    }
    -- opencode.nvim 要求开启 autoread
    vim.o.autoread = true
  end,
  keys = {
    { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
    -- 交互式提问
    { "<leader>aa", function() require("opencode").ask("@this: ") end, desc = "Ask OpenCode", mode = { "n", "v" } },
    -- 选择器（Prompts / Commands / Servers）
    { "<leader>as", function() require("opencode").select() end, desc = "Select", mode = { "n", "v" } },
    -- 内置 Prompt 模板
    { "<leader>ae", function() require("opencode").prompt("explain @this") end, desc = "Explain", mode = { "n", "v" } },
    { "<leader>ar", function() require("opencode").prompt("review @this") end, desc = "Review", mode = { "n", "v" } },
    { "<leader>af", function() require("opencode").prompt("fix @diagnostics") end, desc = "Fix", mode = { "n", "v" } },
    { "<leader>ao", function() require("opencode").prompt("optimize @this") end, desc = "Optimize", mode = { "n", "v" } },
    { "<leader>ad", function() require("opencode").prompt("document @this") end, desc = "Document", mode = { "n", "v" } },
    { "<leader>at", function() require("opencode").prompt("test @this") end, desc = "Add Tests", mode = { "n", "v" } },
    { "<leader>ai", function() require("opencode").prompt("implement @this") end, desc = "Implement", mode = { "n", "v" } },
    -- 会话管理
    { "<leader>ac", function() require("opencode").command("session.new") end, desc = "New Session" },
    { "<leader>al", function() require("opencode").command("prompt.clear") end, desc = "Clear Prompt" },
    -- Diff 管理（opencode 的 diff 窗口使用内置按键 da/dr/dp/do，这里仅提供备用命令）
    { "<leader>aA", function() require("opencode").command("session.last") end, desc = "Scroll to Last" },
  },
}
