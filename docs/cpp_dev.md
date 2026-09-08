# C/C++ 开发环境指南

> 基于当前配置梳理：clangd extra、cmake extra、cmake-tools（overseer 执行器）、codelldb 调试、DAP core、neogen 文档注释、自定义 C/C++ snippets。
> 快捷键总表见 `docs/quick_use.md`，本文只展开 C/C++ 相关。

## 一、当前环境清单

| 组件 | 状态 | 说明 |
|---|---|---|
| clangd | ✅ mason 已装 | 已开 `--clang-tidy`、`--header-insertion=iwyu`（自动补 include）、`--background-index` |
| clangd_extensions.nvim | ✅ 已装 | AST 可视化、符号信息、类型层级 |
| cmake-tools.nvim | ✅ `<leader>C` 组 | Presets 模式，executor/runner 走 overseer |
| neocmakelsp + cmakelang | ✅ mason 已装 | CMakeLists 的 LSP / 诊断；`cmake_format` 格式化（conform 已配） |
| codelldb | ✅ mason 已装 | DAP 调试器，cmake `<leader>Cd` 直连 |
| nvim-dap-virtual-text | ✅ 已装 | 调试时行内显示变量值 |
| neogen | ✅ | 函数文档注释生成（`<leader>cn`） |
| snippets/c.json | ✅ 自定义 C/C++ 片段 | luasnip 提供 |
| overseer file-run | ✅ | 单文件快速运行（可执行位/filetype 检测） |

## 二、日常高频操作

### 代码导航（clangd）

| 键位 | 作用 | 技巧 |
|---|---|---|
| `<leader>ch` | **头文件/源文件切换** | C++ 开发最高频键位 |
| `gd` | 跳转定义 | 跳到头文件声明时再 `gd` 一次通常到实现 |
| `gr` | 查引用 | snacks picker 列表展示（LazyVim `nowait` 覆盖了内置 `grr`，直接按 `gr` 即可） |
| `K` | 悬浮文档 | 标准库/自定义类型都有 |
| `<leader>ss` | 文档符号 | 长头文件找类/函数 |
| `crn` | 重命名（inc-rename） | clangd 支持跨文件重命名，头文件声明同步改 |
| `gl` | 诊断详情 | clang-tidy 的 lint 提示都在这 |
| `]d` / `[d` | 上/下一个诊断 | 配合 clang-tidy 快速过问题 |

### 智能补全特性（已默认开启）

- **补 include**：输入类型/函数名如 `vector`，补全列表出现 `#include <vector>` 选项（iwyu header-insertion）
- **函数参数占位**：补全函数后自动生成参数占位符，Tab 跳转
- **补全排序**：clangd_extensions 的 cmp_scores 已插入排序器，符合 C++ 习惯

## 三、进阶功能

### 1. clangd_extensions（容易被忽略的好东西）

| 命令 | 作用 |
|---|---|
| `:ClangdAST` | **AST 可视化**：光标所在节点的语法树窗口，看模板展开/隐式转换神器 |
| `:ClangdSymbolInfo` | 符号详情（声明位置、大小、vtable 等） |
| `:ClangdTypeHierarchy` | 类型层级（继承树），看虚函数覆盖关系 |
| `:ClangdMemoryUsage` | clangd 自身内存/索引统计 |

建议映射 `:ClangdAST` 到顺手键位，如 `<leader>ca`（AST 而非普通 code action 场景，code action 用 `gra`）。

### 2. CMake 流水线（`<leader>C` 组）

```
Cp 选 Configure Preset（一次）
  ↓
Cg Generate → Cb Build → ]d 跳编译错误 → Cd Debug
```

- Presets 强制启用（`cmake_use_presets = "always"`），构建目录/编译器/选项都在 `CMakePresets.json` 管理，nvwim 侧零配置
- **并行构建**：在 preset 的 `cacheVariables` 加 `"CMAKE_BUILD_PARALLEL_LEVEL"`，或运行时 overseer 侧栏 `<CR>` 编辑命令加 `--parallel`
- 构建任务自动进 overseer 列表（`<leader>ow`）：`<CR>` 重启构建、`<C-q>` 转快速修复逐条跳错误、`p` 悬浮预览输出
- `<leader>Cr` 运行时输出同样走 overseer，长驻进程可后台跑

### 3. compile_commands.json（clangd 准确索引的关键）

- CMake：preset 的 `cacheVariables` 里加 `"CMAKE_EXPORT_COMPILE_COMMANDS": "ON"`，构建后软链到项目根：
  `ln -sf build/<preset>/compile_commands.json .`
- Makefile 项目：`bear -- make` 生成
- 无构建系统的单文件：写 `compile_flags.txt`（每行一个 flag，如 `-std=c++20`）
- 索引未就绪时诊断/补全不全是正常的，`<leader>cm`（Mason）旁的状态可从 lualine 看 LSP 是否 attached

### 4. 调试进阶（codelldb + DAP）

| 键位 | 作用 | 技巧 |
|---|---|---|
| `<leader>Cd` | 编译产物直接调试 | 自动用 preset 的 binaryDir |
| `<leader>db` / `<leader>dB` | 切断点 / **条件断点** | 条件输入表达式如 `i == 42`，循环调试神器 |
| `<leader>dc` / `<leader>di` / `<leader>dO` / `<leader>do` | 继续 / 步入 / 步过 / 步出 | 注意大小写：`O`=over，`o`=out |
| `<leader>da` | 带参数运行 | 调试前输命令行参数 |
| `<leader>dl` | 重跑最近调试 | 改完代码后最快的调试循环 |
| `<leader>dw` / `<leader>de` | 悬浮 watch / 求值表达式 | 可视模式选中表达式 `de` 直接算 |
| `<leader>du` | 开关 DAP UI | 栈帧/watch/断点侧栏 |
| `<leader>dk` / `<leader>dj` | 上/下切换栈帧 | 看调用方上下文 |
| `<leader>dt` | 终止会话 | |

- Attach 进程配置已内置（`Attach to process`），DAP UI 中选该 configuration 即可调试已运行的服务
- REPL（`<leader>dr`）里可调表达式，STL 容器用 codelldb 的 pretty-printer 直接展开
- 调试 CMake 项目失败时先确认 `<leader>Cb` 最新构建成功，binaryDir 与 preset 一致

### 5. 其他技巧

- **保存不格式化**（全局关了 autoformat），C++ 格式化走 clang-format：`<leader>cf`，项目根放 `.clang-format` 即可统一风格（clangd 的 `--fallback-style=llvm` 只影响诊断内嵌格式提示）
- **doc 注释**：`<leader>cn` 在函数上一行生成 doxygen 风格注释（neogen 支持 C++；`<leader>s` 组是 Notes/杂项，与注释无关）
- **snippets**：`snippets/c.json` 里的片段（如 main 模板、类定义），插入式补全里 `<Tab>` 展开；新增片段直接编辑该文件
- **单文件实验**：有可执行位的 `.cpp` 不适合直接跑（需编译），实验代码建议 `g++ -std=c++20 x.cpp && <leader>oo` 跑 file-run；或直接用下面的 Godbolt 插件

## 四、插件推荐（按实用性排序）

| 插件 | 推荐理由 | 安装方式 |
|---|---|---|
| **krady21/compiler-explorer.nvim** | nvim 内直接用 Godbolt：选中代码看多编译器汇编写出（g++/clang++ 各版本对比，体验模板实例化结果），C++ 学习利器 | `lua/plugins/` 新文件，ft=c/cpp 懒加载 |
| **neotest-gtest**（配 test.core） | GoogleTest 集成：`<leader>tt` 直接跑单个 TEST 用例、失败行内标记，代替手写 overseer 任务 | 需要项目用 gtest |
| **HiPhish/rainbow-delimiters.nvim** | 括号彩虹染色——深层嵌套模板（`std::map<std::string, std::vector<int>>`）肉眼可辨配对 | ✅ 已装：`lua/plugins/rainbow-delimiters.lua`，text/json/markdown 等已排除 |
| **fei6409/log-highlight.nvim** | 大型构建日志（overseer quickfix / 输出窗口）里高亮 error/warning 行 | 构建重项目收益明显 |

前两个建议优先试装；rainbow-delimiters 看个人口味。

## 五、易踩坑备忘

1. **clangd 索引炸内存**：超大仓库可加 `--limit-references` / 降低 `--background-index-priority`，或排除第三方目录（`.clangd` 配置文件里 `CompileFlags: Add` / `Remove`）。
2. **头文件单独打开诊断不准**：正常现象，clangd 对无编译上下文的头文件用启发式；确保 `compile_commands.json` 覆盖即可。
3. **切换 C/C++ 标准不生效**：改的是 CMakeLists 而非 compile_commands 时，重新 Generate + 软链，`clangd` 才会看到 `-std=`。
4. **`X`/`bd` 关掉 clangd buffer 不会杀 LSP server**，索引仍在后台，放心切文件。
5. overseer 的 `file-run` 模板对 `.cpp` 不可用（无解释器映射），运行 C++ 一律走构建产物（`<leader>Cr`）或调试（`<leader>Cd`）。
