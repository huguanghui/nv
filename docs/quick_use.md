# LazyVim 快捷键速查表（quick_use.md）

> `<leader>` = 空格键。任何前缀按下后稍等，会弹出 which-key 提示菜单。
> AI 插件当前启用：`avante`（`vim.g.ai_plugin` 可切换 claude / avante / opencode）

---

## 一、日常高频（每天必用）

| 快捷键 | 模式 | 作用 | 技巧 |
|---|---|---|---|
| `jk` | 插入 | 保存并退出插入模式 | 替代 `Esc`，顺手保存 |
| `H` / `L` | 普通 | 上一个 / 下一个 buffer | 相当于 tab 切换 |
| `X` | 普通 | 安全关闭当前 buffer（Snacks.bufdelete） | 不会静默丢弃未保存修改 |
| `<leader><leader>` | 普通 | 模糊查找文件（Snacks Picker） | 最高频入口 |
| `<leader>/` | 普通 | 全局内容搜索（Grep） | 精确搜字符串用 |
| `<leader>e` | 普通 | 打开/关闭 neo-tree 文件树 | `P` 复制 @path 引用，`y` 复制文件名 |
| `<leader>fg` | 普通 | Git 文件搜索 | 只搜 git 跟踪的文件 |
| `gd` / `gr` | 普通 | 跳转定义 / 引用 | LSP 核心导航 |
| `K` | 普通 | 悬浮文档 | |
| `gl` | 普通 | 显示当前行诊断详情 | 自定义：原为 LazyVim 的 location list |
| `<esc>` | 普通 | 清除搜索高亮 | LazyVim 默认 |

**使用技巧**
- 相对行号：普通模式显示相对行号，进入插入模式自动切换绝对行号（autocmds.lua）。配合 `5j`/`12k` 精准跳行。
- 粘贴历史：`<leader>p` 打开 yanky 剪贴历史（yanky extra），`<C-n>`/`<C-p>` 在粘贴后循环选择之前的寄存器内容。
- `;p` 粘贴 yank 寄存器（`"0p`），不会被 delete 内容污染。
- `;c` / `;d` 用黑洞寄存器改/删（不污染剪贴板）。

---

## 二、AI 辅助（`<leader>a`）— Avante 当前启用

| 快捷键 | 模式 | 作用 |
|---|---|---|
| `<leader>aa` | n/v | Ask：打开对话提问 |
| `<leader>ae` | n/v | Edit：选中范围 AI 编辑 |
| `<leader>ar` | n/v | Refactor：重构 |
| `<leader>ao` | n/v | Optimize：优化代码 |
| `<leader>ax` | n/v | Explain：解释代码 |
| `<leader>ab` | n/v | Fix Bugs（自动附带文件类型/文件名上下文） |
| `<leader>av` | n/v | Code Review（Rust 文件自动换成 Rust 设计评审提示词） |
| `<leader>al` | n/v | Clear：清空对话 |

Avante diff 视图中：`co` 用我的版本 / `ct` 用 AI 版本 / `ca` 全部采纳 / `]x` `[x` 跳转 diff 块。
建议补全（Copilot）：`<M-l>` 接受，`<M-]>`/`<M-[>` 切换候选，`<C-]>` 忽略。

### AI 引用快捷复制（配合 AI 工具）

| 快捷键 | 模式 | 作用 |
|---|---|---|
| `<leader>mp` | 普通 | 复制 `@相对路径`（整个文件引用） |
| `<leader>mc` | 可视 | 复制 `@路径:start-end`（代码范围引用） |
| neo-tree 中 `P` | 树内 | 复制节点 `@路径` 引用（目录自动加 `/`） |

复制后直接粘贴到 Claude Code / 终端 AI 工具即可精准引用代码。

### 切换 AI 后端

`vim.g.ai_plugin` = `claude` / `avante` / `opencode`（options.lua），各后端键位速查：

- **claude**（claudecode.nvim）：`<leader>ac` Toggle、`<leader>as` 发送选中、`<leader>aa` 接受 diff、`<leader>ad` 拒绝 diff
- **opencode**：`<leader>as` 选择器、`<leader>ae/ar/af/ao` explain/review/fix/optimize、`<leader>ac` 新会话

---

## 三、文件与窗口

| 快捷键 | 模式 | 作用 | 技巧 |
|---|---|---|---|
| `<leader>e` | 普通 | neo-tree | 树内 `a`/`d`/`r` 增删改，`c-up` 恢复上次 yazi 会话 |
| `<leader>y` | n/v | Yazi 文件管理器（定位到当前文件） | 比 neo-tree 更适合文件移动 |
| `<leader>cw` | 普通 | Yazi 打开当前工作目录 | |
| `<leader>-` | 普通 | Snacks 悬浮文件树 | LazyVim 默认 |
| `<C-h/j/k/l>` | 普通 | 窗口间移动 | |
| `<leader>wd` | 普通 | 关闭窗口 | |
| `<C-up>` | 普通 | 恢复/切换上一次 yazi 会话 | |

### 终端

| 快捷键 | 作用 |
|---|---|
| `<C-/>` | 悬浮终端（LazyVim 默认） |
| `<esc>` | 终端模式退出回普通模式 |
| `<C-h/j/k/l>` | 终端中直接切窗口 |

---

## 四、搜索与编辑

| 快捷键 | 作用 | 技巧 |
|---|---|---|
| `<leader>sg` | Grep 搜索 | 可视模式选中文本后 `<leader>sg` 直接搜 |
| `<leader>sw` | 搜索光标下单词 | |
| `<leader>sk` | 搜索快捷键 | 忘记键位时用这个 |
| `<leader>sb` | 搜索 buffer | |
| `<leader>sd` | 搜索诊断 | |
| `<leader>ss` | 搜索 LSP 符号 | |
| `crn` / `crr` | 重命名（inc-rename 渐进预览）/ 代码动作 | 边打字边看重命名效果 |
| `<leader>cf` | 格式化 | 全局 autoformat 已关闭，手动触发 |
| `]d` / `[d` | 下一个 / 上一个诊断 | |
| `]x` / `[x` | diff 块跳转（Avante 窗口内） | |
| `<leader>uo` | 切换 outline（Aerial 大纲） | 长文件快速跳结构 |
| `ys{motion}` | Yanky：在可视粘贴后循环寄存器 | `<C-n>`/`<C-p>` |

---

## 五、构建 / 运行 / 调试

### CMake 项目（`<leader>C`，大写 C）

| 快捷键 | 作用 |
|---|---|
| `<leader>Cp` | 选择 Configure Preset |
| `<leader>CB` | 选择 Build Preset |
| `<leader>CT` | 选择 Test Preset |
| `<leader>Cg` | CMake Generate |
| `<leader>Cb` | CMake Build |
| `<leader>Cr` | CMake Run |
| `<leader>Cd` | CMake Debug（codelldb） |

### 任务运行（Overseer，已替代 asynctasks）

| 快捷键 / 命令 | 作用 |
|---|---|
| `<leader>oo` | 模糊搜索并执行任务（含自定义 `file-run`、VSCode tasks.json、Makefile 自动发现） |
| `<leader>ow` | 任务列表侧栏 |
| `<leader>ot` | 对当前任务选操作（重启/停止/移除） |
| `:OverseerRestartLast` | 重跑最近任务 |

任务列表侧栏内：`<CR>` 动作菜单、`o`/`<C-v>`/`<C-s>`/`<C-t>`/`<C-f>` 输出开到不同窗口、`<C-q>` 输出转 quickfix、`p` 悬浮预览、`dd` 移除任务。

自定义模板位于 `lua/overseer/template/local.lua`（如需加任务直接在此追加）。

### 调试（DAP core）

`<leader>db` 断点、`<leader>dc` 继续、`<leader>dap` 暂停、`<leader>dt` 终止、F5 类键位由 cmake-tools 联动。

### 测试（test.core）

`<leader>tt` 文件测试 / `<leader>tT` 全部测试 / `<leader>tr` 运行最近测试（ Overseer 执行）。

---

## 六、Git

| 快捷键 | 作用 |
|---|---|
| `<leader>gg` | LazyGit（悬浮全屏） |
| `<leader>gb` | 行 Git blame |
| `<leader>gd` | Diff 视图 |
| `]h` / `[h` | 下一个 / 上一个 hunk |
| `<leader>ghs` / `ghr` | stage / reset hunk |

---

## 七、低频但好用

| 快捷键 | 作用 |
|---|---|
| `<leader>ii` / `ie` / `ic` | 翻译（当前词/选中）→ 默认中文；`ie` 翻成英文 |
| `<leader>l` | LazyVim 信息面板 |
| `<leader>cm` | Mason（LSP 安装管理） |
| `<leader>qq` | 退出全部 |
| `<leader>ul` | 切换行号模式 |
| `<leader>uf` | 切换 autoformat |
| `gcc` / `gc{motion}` | 注释行 / 块 |
| `<leader>sn` | Neogen 生成文档注释（函数 doc） |
| `<leader>bd` / `bo` | 删除 buffer / 删除其他 buffer |
| `vim.g.toggle_theme` | bufferline 右上角图标按钮点击切换主题 |

---

## 八、易混淆点备忘

1. ~~**两套 `<leader>t`**~~：翻译已迁移到 `<leader>i` 组（i18n），`<leader>t` 专属测试，冲突已消除。
2. **`X` 关闭 buffer**：已改为 Snacks.bufdelete，未保存的 buffer 会提示而非强制丢弃。
3. **autoformat 默认关闭**：保存不会自动格式化，需要 `<leader>cf` 手动触发。
4. **SSH 环境**：剪贴板走 OSC 52，`y` 直接同步到本地剪贴板；粘贴建议终端 `Ctrl+Shift+V`。
5. **搜索统一用 snacks picker**（fzf extra 已移除），文件 `<leader><leader>`、内容 `<leader>/`。
6. **键位冲突排查**：发现某个键行为异常时用 `:verbose map <leader>xx` 查看它被谁定义。
