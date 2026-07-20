# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

---

## 自定义快捷键

### 基础编辑

| 按键 | 模式 | 说明 |
|------|------|------|
| `jk` | Insert | 快速退出插入模式并保存 |
| `X` | Normal | 关闭当前 buffer |
| `L` | Normal | 切换到下一个 buffer |
| `H` | Normal | 切换到上一个 buffer |
| `gl` | Normal | 打开诊断信息浮窗 |
| `;p` | Normal | 粘贴上次复制的内容（`"0p`） |
| `;c` | Normal | 剪切到黑穴寄存器（不覆盖复制缓冲区） |
| `;d` | Normal | 删除到黑穴寄存器（不覆盖复制缓冲区） |

### AI 代码引用（Claude Code / Avante 等）

将文件路径转换为 `@仓库相对路径` 格式，方便粘贴到 AI 工具中引用代码。

| 按键 | 模式 | 说明 | 复制格式 |
|------|------|------|----------|
| `<leader>mc` | Visual | 复制选中代码的范围引用 | `@lua/config/keymaps.lua:20-42` |
| `<leader>mp` | Normal | 复制当前文件路径引用 | `@lua/config/keymaps.lua` |
| `P` | Normal (Neo-tree) | 复制文件浏览器选中文件的路径引用 | `@lua/plugins/neo-tree.lua` |

**使用示例**：在 Claude Code 中粘贴 `@lua/config/keymaps.lua:20-42` 即可引用指定代码段。

### Which-key 分组

| 前缀 | 分组名 | 图标 |
|------|--------|------|
| `<leader>a` | AI |  |
| `<leader>m` | Misc |  |

### 文件浏览器（Neo-tree）

| 按键 | 说明 |
|------|------|
| `y` | 复制文件名 |
| `P` | 复制文件的 `@路径` 引用（用于 AI 工具） |
