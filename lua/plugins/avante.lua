local function load_env_from_config()
  local env_file = vim.fn.expand("~/.config/nvim/.env")
  local f = io.open(env_file, "r")
  if f then
    for line in f:lines() do
      local key, value = line:match("^([%w_]+)%s*=%s*(.-)%s*$")
      if key and value and not value:match("^#") then
        vim.env[key] = value
      end
    end
    f:close()
  end
end
load_env_from_config()

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
    enabled = function()
      return vim.g.ai_plugin == "avante"
    end,
    opts = function(_, opts)
      opts.provider = vim.g.ai_provider or "deepseek"
      opts.rag_service = { enabled = false }

      opts.providers = opts.providers or {}
      opts.providers.deepseek = {
        __inherited_from = "openai",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-v4-flash",
        api_key_name = "DEEPSEEK_API_KEY",
        -- use_ReAct_prompt = true,
      }

      opts.behaviour = vim.tbl_extend("force", opts.behaviour or {}, {
        auto_suggestions = false,
        enable_cursor_planning_mode = true,
      })

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
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      })

      if vim.g.ai_provider ~= "copilot" then
        opts.auto_suggestions_provider = "copilot"
      end

      opts.system_prompt = function()
        local prompt = [[
## 编辑规则

当你需要修改代码时，必须使用 `str_replace` 工具，而不是直接输出修改后的代码。

原因：
- 使用工具可以让我在缓冲区中审查每个改动点
- 我可以逐个接受或拒绝每个改动块
- 不这样做会导致无法审查代码变更

`str_replace` 工具的输入参数：
- path: 要修改的文件路径
- old_str: 要替换的原始代码（必须精确匹配，包括缩进和空格）
- new_str: 替换后的新代码

重要：始终使用此工具来修改代码。如果我要求修改代码，第一反应应该是调用 str_replace，而不是输出代码块。
]]

        local u_status, utils = pcall(require, "config.utils")
        if u_status and utils.is_mcp_present() then
          local mcp_prompt = require("mcphub").get_hub_instance():get_active_servers_prompt()
          if mcp_prompt and mcp_prompt ~= "" then
            prompt = prompt .. "\n\n" .. mcp_prompt
          end
        end

        return prompt
      end

      local u_status, utils = pcall(require, "config.utils")
      if u_status and utils.is_mcp_present() then
        opts.custom_tools = {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end

      return opts
    end,
    keys = function(_, keys)
      local avante_prompts = {}
      local p_status, p_mod = pcall(require, "config.prompts")
      if p_status then
        avante_prompts = p_mod.avante
      end

      local custom_keys = {
        { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "Ask", mode = { "n", "v" } },
        { "<leader>al", "<cmd>AvanteClear<cr>", desc = "Clear", mode = { "n", "v" } },

        {
          "<leader>ae",
          function()
            require("avante.api").edit()
          end,
          desc = "Edit",
          mode = { "n", "v" },
        },

        { "<leader>ar", create_avante_call(avante_prompts.refactor), desc = "Refactor", mode = { "n", "v" } },
        { "<leader>ao", create_avante_call(avante_prompts.optimize_code), desc = "Optimize", mode = { "n", "v" } },
        { "<leader>ax", create_avante_call(avante_prompts.explain_code), desc = "Explain", mode = { "n", "v" } },
        { "<leader>ab", create_avante_call(avante_prompts.fix_bugs, true), desc = "Fix Bugs", mode = { "n", "v" } },

        {
          "<leader>av",
          function()
            local prompt = (vim.bo.filetype == "rust") and avante_prompts.rust_design_review
              or avante_prompts.code_review
            create_avante_call(prompt)()
          end,
          desc = "Code Review",
          mode = { "n", "v" },
        },
      }

      return vim.list_extend(keys, custom_keys)
    end,
  },
}
