return {
  "Civitasv/cmake-tools.nvim",
  lazy = true,
  event = "BufReadPost",
  opts = function(_, opts)
    -- 核心配置：设为 "always" 或 "auto"
    -- "always": 强制使用 CMakePresets.json
    -- "auto": 如果项目中有该文件则使用，没有则回退到 Kits/Variants 模式
    opts.cmake_use_presets = "always"

    -- 当使用 Presets 时，构建目录通常在 JSON 中定义，
    -- 这里的配置可以留空，插件会自动读取 Preset 中的 binaryDir
    opts.cmake_build_directory = ""

    -- 其他保持不变
    opts.cmake_runner = { name = "overseer" }
    opts.cmake_executor = { name = "overseer" }

    -- 调试配置
    opts.cmake_dap_configuration = {
      name = "cpp",
      type = "codelldb",
      request = "launch",
      stopOnEntry = false,
      runInTerminal = true,
    }
  end,
  keys = {
    -- 针对 Presets 优化的快捷键
    { "<leader>cp", "<cmd>CMakeSelectConfigurePreset<cr>", desc = "Select Configure Preset" },
    { "<leader>cB", "<cmd>CMakeSelectBuildPreset<cr>", desc = "Select Build Preset" },
    { "<leader>cT", "<cmd>CMakeSelectTestPreset<cr>", desc = "Select Test Preset" },
    { "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "CMake Generate" },
    { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "CMake Build" },
    { "<leader>cr", "<cmd>CMakeRun<cr>", desc = "CMake Run" },
    { "<leader>cd", "<cmd>CMakeDebug<cr>", desc = "CMake Debug" },
  },
}
