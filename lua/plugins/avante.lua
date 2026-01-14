-- local is_online = require("config.utils").is_online
local function create_avante_call(prompt, use_context)
  if use_context then
    local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "unknown"
    local filename = vim.fn.expand("%:t")
    filename = filename ~= "" and filename or "unnamed buffer"
    local context = string.format("This is %s code from file '%s'. ", filetype, filename)
    return function()
      require("avante.api").ask({ question = context .. prompt })
    end
  else
    return function()
      require("avante.api").ask({ question = prompt })
    end
  end
end

return {
  {
    "yetone/avante.nvim",
    opts = function(_, opts)
      -- 扩展文件类型支持
      opts.filetypes = vim.tbl_extend("force", opts.filetypes or {}, {
        ["*"] = false,
        avante = true,
        c = true,
        cpp = true,
        go = true,
        lua = true,
        rust = true,
        python = true,
        markdown = true,
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Avante 配置覆盖
  -----------------------------------------------------------------------------
  {
    "yetone/avante.nvim",
    -- 使用 opts 函数模式来合并 LazyVim 的默认设置
    opts = function(_, opts)
      -- 加载自定义 Prompts
      local avante_prompts = {}
      local p_status, p_mod = pcall(require, "config.prompts")
      if p_status then avante_prompts = p_mod.avante end

      -- 基础配置合并
      opts.provider = "copilot"
      opts.cursor_applying_provider = "copilot"
      opts.rag_service = { enabled = false }

      -- 配置 Copilot Provider 详情
      opts.providers = opts.providers or {}

      -- 行为与交互配置
      opts.behaviour = vim.tbl_extend("force", opts.behaviour or {}, {
        auto_suggestions = false,
        enable_cursor_planning_mode = true,
        minimize_diff = true,
      })

      -- 快捷键映射覆盖 (针对 Avante 内部 UI)
      opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<M-l>", next = "<M-]>", prev = "<M-[>", dismiss = "<C-]>",
        },
      })

      -- 特殊用户 (abz) 的环境变量逻辑覆盖
      if vim.env.USER == "abz" then
        opts.provider = "claude"
        opts.providers.claude = {
          endpoint = os.getenv("LITELLM_ENDPOINT"),
          model = "openrouter-claude-opus-4.5",
          timeout = 50000,
          context_window = 200000,
        }
        opts.auto_suggestions_provider = "copilot"
        opts.web_search_engine = { provider = "tavily" }
      end

      -- MCP 逻辑集成
      local u_status, utils = pcall(require, "config.utils")
      if u_status and utils.is_mcp_present() then
        opts.system_prompt = function()
          return require("mcphub").get_hub_instance():get_active_servers_prompt()
        end
        opts.custom_tools = {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end

      return opts
    end,
    -- 快捷键配置 (基于 Lazy.nvim 的标准方式)
    keys = function(_, keys)
      local avante_prompts = {}
      local p_status, p_mod = pcall(require, "config.prompts")
      if p_status then avante_prompts = p_mod.avante end

      local custom_keys = {
        { "<leader>aa", function() require("avante.api").ask() end,            desc = "Avante: Ask",         mode = { "n", "v" } },
        { "<leader>ae", function() require("avante.api").edit() end,           desc = "Avante: Edit",        mode = { "n", "v" } },
        { "<leader>af", "<cmd>AvanteClear<cr>",                                desc = "Avante: Clear",       mode = { "n", "v" } },
        { "<leader>a?", function() require("avante.api").select_model() end,   desc = "Avante: Select Model" },
        -- 使用自定义 Prompt 函数的映射
        { "<leader>ar", create_avante_call(avante_prompts.refactor),           desc = "Refactor",            mode = { "n", "v" } },
        { "<leader>ao", create_avante_call(avante_prompts.optimize_code),      desc = "Optimize",            mode = { "n", "v" } },
        { "<leader>ax", create_avante_call(avante_prompts.explain_code, true), desc = "Explain",             mode = { "n", "v" } },
        { "<leader>ab", create_avante_call(avante_prompts.fix_bugs, true),     desc = "Fix Bugs",            mode = { "n", "v" } },
        {
          "<leader>av",
          function()
            local prompt = (vim.bo.filetype == "rust") and avante_prompts.rust_design_review or
            avante_prompts.code_review
            create_avante_call(prompt)()
          end,
          desc = "Code Review",
          mode = { "n", "v" },
        },
      }
      return vim.list_extend(keys, custom_keys)
    end,
  }
}
