return {
  "akinsho/bufferline.nvim",
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
}
