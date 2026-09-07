-- 用户自定义 overseer 任务模板（替代原 tasks.ini / asynctasks）
-- 通过 <leader>oo（OverseerRun）模糊搜索执行，<leader>ow 打开任务列表
-- 解释器映射表：filetype → 运行命令前缀
local ft_runners = {
  python = { "python3" },
  lua = { "lua" },
  javascript = { "node" },
  typescript = { "npx", "tsx" },
  sh = { "bash" },
  bash = { "bash" },
  zsh = { "zsh" },
  go = { "go", "run" },
  ruby = { "ruby" },
  perl = { "perl" },
}

-- generator 形式：按当前 buffer 动态生成任务
-- 有解释器映射或文件有可执行位时，提供 file-run 任务
return {
  generator = function(opts, cb)
    local tmpls = {}
    local ft = opts.filetype or ""
    local file = vim.fn.expand("%:p")
    local prefix = ft_runners[ft]

    if file ~= "" and prefix then
      table.insert(tmpls, {
        name = "file-run",
        desc = "运行当前文件（" .. ft .. "）",
        builder = function()
          return {
            cmd = vim.list_extend(vim.deepcopy(prefix), { file }),
            components = {
              { "on_output_quickfix", open_on_match = true },
              "default",
            },
          }
        end,
      })
    elseif file ~= "" and vim.bo.buftype == "" and vim.fn.executable(file) == 1 then
      table.insert(tmpls, {
        name = "file-run",
        desc = "运行当前文件（可执行）",
        builder = function()
          return {
            cmd = { file },
            components = {
              { "on_output_quickfix", open_on_match = true },
              "default",
            },
          }
        end,
      })
    end

    cb(tmpls)
  end,
}
