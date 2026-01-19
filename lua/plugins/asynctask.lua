-- 配置 skywind3000/asynctasks.vim + asyncrun.vim
-- 提供任务管理、异步构建/运行/测试等功能，类似 VSCode Tasks
return {
  -- 主插件：asynctasks.vim
  {
    "skywind3000/asynctasks.vim",
    dependencies = {
      "skywind3000/asyncrun.vim",
    },

    -- 推荐使用 cmd 延迟加载，只有执行相关命令时才真正加载
    cmd = {
      "AsyncTask",
      "AsyncTaskEdit",
      "AsyncTaskList",
      "AsyncTaskMacro",
      "AsyncTaskProfile",
      "AsyncRun",
    },

    -- init 在插件加载前执行，适合设置全局变量
    init = function()
      -- 常用设置（从你的原配置迁移）
      vim.g.asyncrun_open = 8  -- quickfix 窗口高度（8 行），0=不自动打开

      -- 自定义模板文件路径（建议放在 nvim 配置目录下）
      vim.g.asynctask_template = vim.fn.stdpath("config") .. "/task_template.ini"

      -- 额外任务配置文件（支持数组，多个文件优先级从左到右递减）
      vim.g.asynctasks_extra_config = {
        vim.fn.stdpath("config") .. "/tasks.ini",          -- 全局/个人通用任务
        -- vim.fn.getcwd() .. "/.tasks",                   -- 可选：项目级 .tasks 文件（git 忽略）
      }

      -- 其他推荐设置（可选，根据需要开启）
      vim.g.asyncrun_rootmarks = { ".git", ".svn", ".root", ".project", "Makefile" }  -- 项目根目录识别标记
      vim.g.asyncrun_save = 1          -- 运行前自动保存文件
      vim.g.asyncrun_mode = "term"     -- 默认用终端模式运行（可改成 quickfix / silent 等）
      vim.g.asyncrun_trim = 1          -- 去除输出末尾空行
    end,

    -- 可选：插件加载后执行的额外配置（如 keymaps）
    config = function()
      -- 常用快捷键示例（<leader> 可自定义，LazyVim 默认 <leader> = 空格）
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- 运行当前文件（file-run 任务）
      -- map("n", "<leader>rr", "<cmd>AsyncTask file-run<cr>", vim.tbl_extend("force", opts, { desc = "AsyncTask: Run current file" }))

      -- 构建当前文件（file-build）
      -- map("n", "<leader>rb", "<cmd>AsyncTask file-build<cr>", vim.tbl_extend("force", opts, { desc = "AsyncTask: Build current file" }))

      -- 项目构建（project-build）
      -- map("n", "<leader>pb", "<cmd>AsyncTask project-build<cr>", vim.tbl_extend("force", opts, { desc = "AsyncTask: Project build" }))

      -- 项目运行（project-run）
      -- map("n", "<leader>pr", "<cmd>AsyncTask project-run<cr>", vim.tbl_extend("force", opts, { desc = "AsyncTask: Project run" }))

      -- 列出所有可用任务
      -- map("n", "<leader>tl", "<cmd>AsyncTaskList<cr>", vim.tbl_extend("force", opts, { desc = "AsyncTask: List tasks" }))

      -- 编辑当前项目/全局任务文件
      -- map("n", "<leader>te", "<cmd>AsyncTaskEdit<cr>", vim.tbl_extend("force", opts, { desc = "AsyncTask: Edit tasks" }))
    end,
  },

  -- 可选增强：Telescope 集成 asynctasks（强烈推荐，模糊搜索任务超方便）
  -- 如果你用 Telescope（LazyVim 默认有），可以加这个扩展
  {
    "GustavoKatel/telescope-asynctasks.nvim",
    dependencies = {
      "skywind3000/asynctasks.vim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("asynctasks")
    end,
    keys = {
      { "<leader>ft", "<cmd>Telescope asynctasks all<cr>", desc = "Tasks: All available" },
      { "<leader>fT", "<cmd>Telescope asynctasks project<cr>", desc = "Tasks: Project only" },
    },
  },
}
