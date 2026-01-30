return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options = opts.options or {}

      -- hover显示开关按钮控制
      opts.options.hover = opts.options.hover or {}
      opts.options.hover.enabled = true
      opts.options.hover.reveal = { "close" }

      -- 自定义右上角区域
      opts.options.custom_areas = opts.options.custom_areas or {}
      opts.options.custom_areas.right = function()
        return {
          { text = "%@TbToggle_theme@" .. vim.g.toggle_theme_icon .. "%X" },
          { text = "%@Quit_vim@󰗼 %X", fg = "#f7768e" },
        }
      end

      -- 定義所有自訂分組（覆蓋或擴充預設 items）
      opts.options.groups.items = {
        -- 保留 LazyVim 可能有的預設 pinned / ungrouped（如果有）
        require("bufferline.groups").builtin.pinned:with({ icon = "" }),
        require("bufferline.groups").builtin.ungrouped,

        -- 自订分组
        {
          name = "Internals",
          highlight = { fg = "#ECBE7B" },
          matcher = function(buf)
            return vim.startswith(buf.path, vim.env.VIMRUNTIME)
          end,
        },
        {
          name = "Tests",
          icon = "",
          highlight = { sp = "#51AFEF" },
          matcher = function(buf)
            local name = vim.api.nvim_buf_get_name(buf.id)
            local patterns = { "_spec", "_test", "test_" }
            for _, pat in ipairs(patterns) do
              if name:match(pat) then
                return true
              end
            end
            return false
          end,
        },
        {
          name = "Terraform",
          matcher = function(buf)
            return buf.name:match("%.tf$")
          end,
        },
        {
          name = "SQL",
          matcher = function(buf)
            return vim.api.nvim_buf_get_name(buf.id):match("%.sql$")
          end,
        },
        {
          name = "View models",
          highlight = { sp = "#03589C" },
          matcher = function(buf)
            return vim.api.nvim_buf_get_name(buf.id):match("view_model%.dart")
          end,
        },
        {
          name = "Screens",
          icon = "󰐯",
          matcher = function(buf)
            return buf.path:match("screen")
          end,
        },
        {
          name = "Docs",
          highlight = { sp = "#C678DD" },
          matcher = function(buf)
            local ext = vim.fn.fnamemodify(buf.path, ":e")
            local doc_exts = { md = true, txt = true, org = true, norg = true, wiki = true }
            return doc_exts[ext] or false
          end,
        },
        {
          name = "Config",
          highlight = { sp = "#F6A878" },
          matcher = function(buf)
            local name = vim.api.nvim_buf_get_name(buf.id)
            local parts = vim.split(name, "/", { plain = true })
            local filename = parts[#parts]
            if not filename then
              return false
            end
            local config_files = {
              ["go.mod"] = true,
              ["go.sum"] = true,
              ["Cargo.toml"] = true,
              ["manage.py"] = true,
              ["Makefile"] = true,
            }
            return config_files[filename] or false
          end,
        },
        {
          name = "Terms",
          auto_close = true,
          matcher = function(buf)
            return buf.path:match("^term://")
          end,
        },
      }

      -- 外观微调
      opts.options.show_close_icon = false
      opts.options.indicator = { icon = "▎", style = "icon" }
      opts.options.max_name_length = 18
      opts.options.max_prefix_length = 15
      opts.options.truncate_names = true
      opts.options.tab_size = 18
      opts.options.color_icons = true
      opts.options.show_buffer_close_icons = true

      return opts
    end,
  },
}
