vim.g.autoformat = false

-- 检测是否在 SSH 环境下
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  -- 定义一个强制使用 OSC 52 的剪切板后端
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    -- 注意：OSC 52 粘贴由于安全原因，大多数终端默认禁用
    -- 这里我们依然配置它，但粘贴建议用终端的快捷键 (Ctrl+Shift+V)
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }

  -- 开启 unnamedplus，让 y 直接同步到系统剪切板（即上面的 OSC 52）
  vim.opt.clipboard = "unnamedplus"
end

