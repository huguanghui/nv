# 嵌入式 Linux C/C++ 开发指南

> 本文聚焦**嵌入式 Linux 交叉开发**场景（交叉编译、部署、串口、远程调试）。
> 通用 C/C++ 编辑/导航/调试键位见 `docs/cpp_dev.md`，完整快捷键见 `docs/quick_use.md`，本文不重复。
> 环境快照：2026-09-28。工具链路径与 mason 包会随环境变化，使用前用 `ls /opt` / `:Mason` 复核。

## 一、当前环境盘点（嵌入式相关）

| 组件 | 状态 | 说明 |
| --- | --- | --- |
| clangd | ✅ mason 23.1.0 | LSP 主力；`~/.local/share/nvim/mason/bin/clangd` |
| clangd_extensions.nvim | ✅ | AST / 类型层级 / 符号信息 / 内存统计 |
| cmake-tools.nvim | ✅ `<leader>C` 组 | Presets 模式，runner/executor 走 overseer |
| codelldb | ✅ mason | DAP 调试器，支持本地 + **远程 gdbserver** |
| nvim-dap / dap-ui / dap-virtual-text | ✅ | 调试 UI、行内变量 |
| overseer.nvim | ✅ | 构建/部署/串口任务统一入口 |
| tio | ✅ 系统 v2.7 | 串口终端（`/usr/bin/tio`） |
| gdb（host） | ✅ 系统 15.0 | 支持 `-i dap`；多架构支持有限 |
| rsync / scp / ssh | ✅ | 部署到目标板 |
| make / cmake / ninja | ✅ | 构建 |
| gitsigns / lazygit | ✅ | 补丁/提交管理 |
| clang-format | ❌ 未装 | mason registry 有，可 `:MasonInstall clang-format` |
| bear / cppcheck / cscope / global | ❌ | 按需 `apt install`（mason 无） |

### 交叉工具链（`/opt` 下）

| 前缀 | 路径 | 目标 |
| --- | --- | --- |
| `arm-rel-linux-uclibcgnueabihf-` | `/opt/arm-rel-linux-uclibcgnueabihf/bin` | ARM + uclibc |
| `arm-sigmastar-linux-uclibcgnueabihf-` | `/opt/arm-sigmastar-linux-uclibcgnueabihf-9.1.0/bin` | ARM + uclibc（SigmaStar） |
| `arm-linux-gnueabihf-` | `/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin` | ARM + glibc |
| `mips-linux-gnu-` | `/opt/mips-gcc720-glibc229-r5.1.9/bin` | MIPS（含 uclibc sysroot / gdbserver） |

每套都自带 `gcc/g++/gdb`。**调试目标板时优先用对应工具链的 gdb**（与目标 glibc/uclibc 匹配），host gdb 15 主要用于本地。

## 二、高频工作流总览

```
┌─ 编辑/索引 ─────────────────────────────────────────────┐
│ clangd（query-driver 指向交叉 gcc）← compile_commands.json │
│ <leader>ch 切头/源  gd/gr/K  补全  保存不自动格式化        │
└─────────────────────────────────────────────────────────┘
              │
              ▼
┌─ 交叉构建 ──────────────────────────────────────────────┐
│ <leader>Cp 选 Configure Preset（含 toolchainFile）        │
│ <leader>Cg → <leader>Cb（产物进 overseer，]d 跳错误）     │
└─────────────────────────────────────────────────────────┘
              │
      ┌───────┴────────┐
      ▼                ▼
┌─ 本地调试 ─┐   ┌─ 部署/远程 ───────────────────────────┐
│ <leader>Cd │   │ scp/rsync → ssh 运行 → 串口 tio 看日志 │
│ codelldb   │   │ gdbserver + codelldb 远程断点调试      │
└────────────┘   └───────────────────────────────────────┘
```

## 三、交叉编译 + clangd 索引（最关键的一环）

### 1. CMake：导出 compile_commands.json 并指定工具链

`CMakePresets.json`（示例）：

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "arm-uclibc-debug",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/arm-uclibc-debug",
      "toolchainFile": "${sourceDir}/cmake/toolchain-arm-uclibc.cmake",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug",
        "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
      }
    }
  ]
}
```

`cmake/toolchain-arm-uclibc.cmake`（示例）：

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(TOOLCHAIN_ROOT /opt/arm-rel-linux-uclibcgnueabihf)
set(CMAKE_C_COMPILER   ${TOOLCHAIN_ROOT}/bin/arm-rel-linux-uclibcgnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_ROOT}/bin/arm-rel-linux-uclibcgnueabihf-g++)
set(CMAKE_SYSROOT      ${TOOLCHAIN_ROOT}/arm-rel-linux-uclibcgnueabihf/sysroot) # 按实际调整
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

构建后把数据库软链到项目根，clangd 才能找到：

```bash
ln -sf build/arm-uclibc-debug/compile_commands.json .
```

- **Makefile 项目**：`bear -- make -j` 生成（需 `apt install bear`）。
- **无构建系统**：项目根写 `compile_flags.txt`，每行一个 flag（如 `-std=c++17`、`-Iinclude`）。

### 2. clangd 必须知道交叉工具链的 sysroot（`--query-driver`）

mason 的 clangd 是 host 版，默认不知道交叉 gcc 的系统头文件，会出现「找不到 `stdint.h`/`bits/...`」。解决：让 clangd 查询交叉 gcc 的 include 搜索路径。

`lua/plugins/clangd.lua`（新建）：

```lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          -- 关键：允许 clangd 调用这些交叉 gcc 来探测系统头文件
          "--query-driver=/opt/arm-rel-linux-uclibcgnueabihf/bin/*-gcc,"
            .. "/opt/arm-sigmastar-linux-uclibcgnueabihf-9.1.0/bin/*-gcc,"
            .. "/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/*-gcc,"
            .. "/opt/mips-gcc720-glibc229-r5.1.9/bin/*-gcc",
        },
      },
    },
  },
}
```

> 注意：`--query-driver` 的 glob 由 clangd 内部匹配，路径要能命中 compile_commands.json 里记录的编译器。改动后重启 LSP（`:LspRestart`）。

### 3. `.clangd`：按目录微调（可选）

项目根 `.clangd`：

```yaml
CompileFlags:
  Add: [-std=c++17, -D__EMBEDDED__]
  # 交叉编译时若仍有系统头告警，可显式补 sysroot：
  # Add: [-isystem, /opt/arm-rel-linux-uclibcgnueabihf/arm-rel-linux-uclibcgnueabihf/sysroot/usr/include]
Diagnostics:
  Suppress: ['-Wunused-parameter']
Index:
  Background: Build
```

大仓库怕 clangd 吃内存时，用 `.clangd` 排除第三方目录（`Index.StandardLibrary: false`、或用 `--background-index-priority=low`）。

## 四、调试

### 1. 本地调试（已有）

- `<leader>Cd`：cmake-tools 直接调试构建产物（codelldb）。
- 断点/步进/watch 键位见 `docs/cpp_dev.md`；`<leader>uh` 开关行内变量提示（inlay hints）。

### 2. 远程调试（目标板 gdbserver）— 嵌入式核心流程

codelldb 支持 gdbserver 协议（也兼容 OpenOCD/QEMU）。目标板上：

```bash
# 目标板（ARM）
gdbserver :2345 /usr/bin/app        # 或用工具链 sysroot 里的 gdbserver
```

`lua/plugins/dap.lua`（新建，给 c/cpp 增加远程配置）：

```lua
return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")
    for _, lang in ipairs({ "c", "cpp" }) do
      dap.configurations[lang] = dap.configurations[lang] or {}
      table.insert(dap.configurations[lang], {
        name = "Remote attach (gdbserver/OpenOCD)",
        type = "codelldb",
        request = "attach",
        targetCreateCommands = {
          -- 本地带调试符号的 ELF（与目标板同一份构建产物）
          "target create ${workspaceFolder}/build/arm-uclibc-debug/app",
        },
        processCreateCommands = {
          -- 目标板地址:端口；OpenOCD/bare-metal 也走这里
          "gdb-remote 192.168.1.10:2345",
        },
        -- 若目标板源码路径与本地不一致，用 sourceMap 重映射
        -- sourceMap = { ["/home/build/app"] = "${workspaceFolder}" },
      })
      table.insert(dap.configurations[lang], {
        name = "Open core dump",
        type = "codelldb",
        request = "attach",
        targetCreateCommands = { "target create -c ${workspaceFolder}/core" },
        processCreateCommands = {},
      })
    end
  end,
}
```

用法：目标板起 `gdbserver` → nvim 里 `<leader>dc`（或 `<leader>db` 下断点后）选该 configuration。

**MIPS / 老旧 uclibc 目标**：codelldb 的 LLDB 对 MIPS 支持较弱，改用工具链自带 gdb（如 `/opt/mips-gcc720-glibc229-r5.1.9/bin/mips-linux-gnu-gdb`）在终端里 `target remote host:port`；或用 host 的 `gdb-multiarch`（`apt install gdb-multiarch`，≥14 可配 nvim-dap 的 `gdb` adapter）。

### 3. gdbserver 版本匹配

主机 gdb 与目标板 gdbserver 协议版本需兼容。优先用**同一工具链**的 gdb + gdbserver（如 arm-rel 的 gdb 8.2.1 配其 sysroot 里的 gdbserver）。codelldb 一般能连常见 gdbserver，但若报协议错误，就换回工具链 gdb。

## 五、串口与终端

```bash
tio /dev/ttyUSB0                 # 默认 115200 8N1
tio -b 115200 -e 5 /dev/ttyUSB0  # 指定波特率/字符间隔
```

- 串口权限：把用户加入 `dialout` 组（`sudo usermod -aG dialout $USER`，重新登录生效）。
- **独占**：tio 会独占串口，同一设备不能再被 minicom/picocom 打开；nvim 里用 snacks 终端开 tio 后，其他窗口别再抢。
- 在 nvim 内开串口（新建 `lua/plugins/terminal.lua` 或加到现有配置）：

```lua
vim.keymap.set("n", "<leader>os", function()
  local port = vim.fn.input("serial port: ", "/dev/ttyUSB0")
  Snacks.terminal.open({ "tio", "-b", "115200", port }, { win = { position = "bottom" } })
end, { desc = "Serial console (tio)" })
```

## 六、部署 / 运行 / 烧录（Overseer 任务）

新增 `lua/overseer/template/embedded.lua`（**必须用 generator 形式**，否则当前 overseer 版本会静默忽略）：

```lua
-- 嵌入式常用任务：部署、远程运行、串口、交叉构建
return {
  generator = function(opts, cb)
    local root = vim.fn.getcwd()
    local file = vim.fn.expand("%:p")
    local tmpls = {}

    local function target()
      return vim.fn.input("target (user@host): ", "root@192.168.1.10")
    end

    -- 交叉构建（若不用 cmake-tools 的 <leader>Cb）
    table.insert(tmpls, {
      name = "cross-build",
      desc = "交叉构建（cmake --build）",
      builder = function()
        return {
          cmd = { "cmake", "--build", "build/arm-uclibc-debug", "-j" },
          cwd = root,
          components = { { "on_output_quickfix", open_on_match = true }, "default" },
        }
      end,
    })

    -- 部署当前构建产物到目标板
    table.insert(tmpls, {
      name = "deploy",
      desc = "rsync 部署到目标板",
      params = { { name = "host", type = "string", default = "root@192.168.1.10" } },
      builder = function(params)
        return {
          cmd = { "rsync", "-avz", "build/arm-uclibc-debug/app", params.host .. ":/usr/bin/" },
          cwd = root,
          components = { { "on_output_quickfix", open_on_match = true }, "default" },
        }
      end,
    })

    -- 远程运行并回显输出
    table.insert(tmpls, {
      name = "run-remote",
      desc = "在目标板运行并回显输出",
      params = { { name = "host", type = "string", default = "root@192.168.1.10" } },
      builder = function(params)
        return {
          cmd = { "ssh", params.host, "/usr/bin/app" },
          cwd = root,
          components = { "default" },
        }
      end,
    })

    -- 打开串口
    table.insert(tmpls, {
      name = "serial",
      desc = "串口终端（tio）",
      params = { { name = "port", type = "string", default = "/dev/ttyUSB0" } },
      builder = function(params)
        return { cmd = { "tio", "-b", "115200", params.port }, components = { "default" } }
      end,
    })

    -- 当前可执行文件直接跑（沿用 local.lua 的思路）
    if file ~= "" and vim.fn.executable(file) == 1 then
      table.insert(tmpls, {
        name = "file-run",
        desc = "运行当前文件（可执行）",
        builder = function()
          return { cmd = { file }, components = { "default" } }
        end,
      })
    end

    cb(tmpls)
  end,
}
```

用法：`<leader>oo` 模糊选任务，`<leader>ow` 打开任务列表（`<CR>` 重启、`<C-q>` 转 quickfix）。

## 七、额外配置优化（按收益排序）

### 1. clangd：`--query-driver`（**必做**，见第三节）

没有它，交叉编译项目在 nvim 里补全/诊断基本不可用。

### 2. clang-format 格式化（补上当前缺口）

现状：`conform` 对 c/cpp **没有配置 formatter**，`<leader>cf` 实际走 clangd 的 LSP 格式化（能用，但无 format-on-save、不能按范围）。想要更可控：

```bash
:MasonInstall clang-format
```

```lua
-- 追加到 lua/plugins/formatting.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
  },
}
```

项目根放 `.clang-format` 统一风格：

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 100
AllowShortFunctionsOnASingleLine: Empty
```

### 3. clangd_extensions 键位（AST / 类型层级 / 内存）

`lua/plugins/clangd.lua` 追加：

```lua
{
  "p00f/clangd_extensions.nvim",
  ft = { "c", "cpp" },
  keys = {
    { "<leader>cT", "<cmd>ClangdAST<cr>", desc = "Clangd AST", ft = { "c", "cpp" } },
    { "<leader>cY", "<cmd>ClangdTypeHierarchy<cr>", desc = "Type Hierarchy", ft = { "c", "cpp" } },
    { "<leader>cU", "<cmd>ClangdMemoryUsage<cr>", desc = "Clangd Memory", ft = { "c", "cpp" } },
  },
}
```

> 键位避让：LazyVim 已占用 `<leader>cA`（Source Action）、`<leader>cD`、`<leader>cM`、`<leader>cs`，故这里选空闲的 `cT/cY/cU`；串口键用 `<leader>os`（`<leader>o` 组是任务）。

### 4. nvim-lint 增加 cppcheck（可选）

clangd 的 `--clang-tidy` 已提供 clang-tidy 诊断；若还想要 cppcheck：

```bash
sudo apt install cppcheck
```

```lua
{
  "mfussenegger/nvim-lint",
  opts = { linters_by_ft = { c = { "cppcheck" }, cpp = { "cppcheck" } } },
}
```

### 5. 交叉调试所需工具（按需 apt）

| 工具 | 用途 |
| --- | --- |
| `bear` | Makefile 项目生成 compile_commands.json |
| `gdb-multiarch` | 主机侧多架构 gdb（≥14 可配 nvim-dap `gdb` adapter） |
| `cppcheck` | 静态检查 |
| `cscope` / `global` | 内核等超大代码库的符号检索（配合 ctags 更好） |

### 6. 内核/驱动开发补充（可选）

- `sparse` / `checkpatch.pl`：内核补丁检查，可做成 overseer 任务。
- 大仓库用 `cscope`/`global` 建库，`cscope` 查询比 LSP 更省内存。
- 二进制/寄存器查看：`:set ft=xxd` + `xxd`，或 `:%!xxd` 编辑固件片段。

## 八、技巧与踩坑

1. **clangd 找不到交叉头文件**：99% 是没配 `--query-driver`，或 `compile_commands.json` 里的编译器路径与 glob 不匹配。先看 `:LspInfo`，再用 `clangd --check=<file>` 在终端复现。
2. **切换 C/C++ 标准不生效**：改的是 CMakeLists 而没重新 Generate/软链，clangd 看不到新的 `-std=`。
3. **调试符号**：远程调试要 `-g` 构建且**本地与目标板同一份产物**；`CMAKE_BUILD_TYPE=Debug`。
4. **路径重映射**：目标板源码路径与本地不同时，用 codelldb `sourceMap`（见第四节）。
5. **gdbserver 连不上**：确认目标板防火墙/端口、`gdbserver :2345` 已监听；主机用 `telnet host 2345` 粗验。
6. **串口被占用**：tio 独占设备，先关掉其他串口程序；权限问题看 `dialout` 组。
7. **attach 被拒**：本地 attach 受 `ptrace_scope` 限制（`cat /proc/sys/kernel/yama/ptrace_scope`）。
8. **剪贴板**：SSH 下走 OSC52，`y` 同步到本地；粘贴用终端 `Ctrl+Shift+V`（配置见 `options.lua`）。
9. **保存不自动格式化**：`vim.g.autoformat = false`，需要 `<leader>cf` 手动触发（或临时 `<leader>uf` 开）。
10. **`<leader>cn` 是 Neogen**（不是 `<leader>sn`，`quick_use.md` 该处有误）。

## 九、建议扩展清单

| 扩展 | 收益 | 方式 |
| --- | --- | --- |
| clangd `--query-driver` | 交叉项目 LSP 可用性（最高） | `lua/plugins/clangd.lua` |
| codelldb 远程 gdbserver 配置 | 目标板断点调试 | `lua/plugins/dap.lua` |
| overseer 嵌入式任务模板 | 构建/部署/运行/串口一键化 | `lua/overseer/template/embedded.lua` |
| clang-format + conform | 统一风格、可 format-on-save | `:MasonInstall clang-format` |
| clangd_extensions 键位 | AST/类型层级排障 | `lua/plugins/clangd.lua` |
| 串口快捷键 | nvim 内直接开 tio | `lua/plugins/terminal.lua` |
| fei6409/log-highlight.nvim | 构建日志 error/warning 高亮 | `lua/plugins/` |
| diffview.nvim | 复杂补丁/合并审查 | `lua/plugins/` |

> 新增插件后记得 `:Lazy sync`、更新 `lazy-lock.json` 并提交；键位变化同步 `quick_use.md`。
