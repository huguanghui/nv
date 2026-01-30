return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts.routes = opts.routes or {}
    vim.list_extend(opts.routes, {
      -- 过滤 "written" / "yanked" 等琐碎写文件消息
      { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      { filter = { event = "msg_show", kind = "", find = "yanked" }, opts = { skip = true } },

      -- 过滤 search wrap 提示（很多人觉得烦）
      { filter = { event = "msg_show", find = "search hit BOTTOM" }, opts = { skip = true } },
      { filter = { event = "msg_show", find = "search hit TOP" }, opts = { skip = true } },

      -- 过滤一些 LSP 的琐碎进度消息（视项目而定）
      { filter = { event = "lsp", kind = "progress" }, opts = { skip = true } }, -- 如果你不喜欢进度条

      -- 只显示 error/warn 级别的消息用 popup，其他用 mini（右下小提示）
      {
        filter = { event = "msg_show", min_height = 10 },
        view = "notify", -- 用 notify 显示大消息
      },
    })
    -- cmdline 位置与行为优化
    opts.cmdline = opts.cmdline or {}
    opts.cmdline.view = "cmdline_popup" -- 默认浮动弹窗（LazyVim 常用）

    -- 推荐：把 cmdline 移到屏幕中央（更符合现代编辑器习惯）
    opts.views = opts.views or {}
    opts.views.cmdline_popup = {
      position = {
        row = "50%", -- 垂直居中
        col = "50%", -- 水平居中
      },
      size = {
        width = "auto",
        min_width = 80, -- 建议 70~100，避免太窄看不清长命令
        height = "auto",
      },
      border = { style = "rounded" },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "FloatBorder" },
      },
    }

    -- cmdline 补全菜单位置（避免和 cmdline 重叠）
    opts.views.cmdline_popupmenu = {
      relative = "editor",
      position = {
        row = "67%", -- 比 cmdline 稍低
        col = "50%",
      },
      size = { width = 80, height = "auto", max_height = 15 },
      border = { style = "rounded" },
    }

    -- 性能相关微调
    opts.lsp = opts.lsp or {}
    opts.lsp.progress = {
      enabled = true, -- 保留 LSP 进度（很多人喜欢）
      -- enabled = false,      -- 如果觉得卡，可完全关闭
      format = " {msg} {percentage}%", -- 简化进度显示
    }

    -- 消息显示超时（减少残留弹窗）
    opts.notify = {
      enabled = true,
      timeout = 3000, -- 3 秒自动消失（默认 5 秒，可调短）
    }

    return opts
  end,
}
