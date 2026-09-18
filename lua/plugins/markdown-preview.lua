return {
  -- Markdown 浏览器预览（自建 fork：huguanghui/markdown-preview.nvim）。
  -- 当前 nvim 跑在 SSH + tmux 且无 DISPLAY，插件无法拉起浏览器：
  --   1) 固定 8113 端口并打印预览地址，配合 `ssh -L 8113:127.0.0.1:8113` 在本机浏览器查看；
  --   2) 打开预览前先清掉占用 8113 的旧 markdown-preview 服务，避免端口冲突导致启动失败。
  -- 注意：端口固定意味着同时只保留一个预览服务，多个 nvim 实例预览时会互相顶掉。
  {
    "huguanghui/markdown-preview.nvim",
    init = function()
      vim.g.mkdp_port = "8113" -- 固定端口，方便 SSH 端口转发
      vim.g.mkdp_echo_preview_url = 1 -- 在 :messages / 命令行打印预览地址
      vim.g.mkdp_auto_close = 0 -- 切走 buffer 时不关闭预览页（combine_preview 要求）
      -- 复用同一个预览页：切换 markdown 文件时，已打开的浏览器标签自动切换内容，
      -- 无需知道 /page/<bufnr> 编号，也无需在浏览器里改地址。
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_combine_preview_auto_refresh = 1 -- 切到别的 md buffer 时自动切页
    end,
    config = function()
      -- 刷新 404 的修复（/ 与 /<number> 302 到 /page/<number>）已包含在 fork 的 app/routes.js 中，这里不再打补丁。
      local port = tonumber(vim.g.mkdp_port) or 8113

      --- 进程是否存活
      local function alive(pid)
        vim.fn.system({ "kill", "-0", pid })
        return vim.v.shell_error == 0
      end

      --- 取监听指定端口的进程 PID 列表（优先 lsof，回退 ss）
      local function pids_on_port()
        local pids = {}
        if vim.fn.executable("lsof") == 1 then
          for _, pid in ipairs(vim.fn.systemlist({ "lsof", "-ti", ("tcp:%d"):format(port) })) do
            pid = vim.trim(pid)
            if pid:match("^%d+$") then
              pids[#pids + 1] = pid
            end
          end
        end
        if #pids == 0 and vim.fn.executable("ss") == 1 then
          for _, line in ipairs(vim.fn.systemlist({ "ss", "-ltnp", ("sport = :%d"):format(port) })) do
            for pid in line:gmatch("pid=(%d+)") do
              pids[#pids + 1] = pid
            end
          end
        end
        return pids
      end

      --- 清理占用预览端口的 markdown-preview 服务（只杀该插件进程，避免误杀其它程序）
      local function kill_stale()
        local killed = {}
        for _, pid in ipairs(pids_on_port()) do
          local args = vim.fn.system({ "ps", "-p", pid, "-o", "args=" })
          if args:find("markdown-preview", 1, true) then
            vim.fn.system({ "kill", pid })
            -- 最多等 1s 优雅退出，否则强杀
            if not vim.wait(1000, function()
              return not alive(pid)
            end, 50) then
              vim.fn.system({ "kill", "-9", pid })
            end
            killed[#killed + 1] = pid
          end
        end
        if #killed > 0 then
          vim.notify(("[markdown-preview] 已清理占用 %d 端口的旧服务: %s"):format(port, table.concat(killed, ", ")))
        end
      end

      --- 仅在“当前 nvim 自己没有预览服务”时才清理端口占用。
      --- 若本 nvim 已有服务（get_server_status()==1），说明端口是自己在用，绝不动它——
      --- 否则同一次会话里预览第二个文件时会把正在用的服务杀掉，导致预览中断。
      local function cleanup_stale()
        if vim.fn["mkdp#rpc#get_server_status"]() == 1 then
          return
        end
        kill_stale()
      end

      -- 手动强制清理（排障用）
      _G.MkdpKillStale = kill_stale
      vim.api.nvim_create_user_command("MkdpKillStale", kill_stale, {
        desc = "清理占用 markdown 预览端口的旧服务",
      })

      -- 插件加载（即本会话首次预览前）：若端口被上次崩溃残留的服务占用，先清理掉，再启动新服务
      cleanup_stale()

      -- 覆盖了 LazyVim markdown extra 的 config，这里要自己补回：加载后为当前 buffer 注册 mkdp 命令
      vim.cmd([[do FileType]])
    end,
  },
}
