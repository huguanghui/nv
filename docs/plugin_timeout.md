# Lazy Update 插件超时问题分析与解决

> 环境：Neovim + LazyVim / lazy.nvim，国内网络，所有 GitHub 访问经本地 Clash 代理
> 日期：2026-09-04

## 一、问题描述

执行 `:Lazy update` 更新插件时，**总有 1–2 个插件“等待超时”**（lazy.nvim 报 git 进程超时并终止）。

- 掉队的插件是谁基本随机（yanky.nvim、mini.icons、SchemaStore… 都中过招），跟仓库大小无关。
- 因为这几个插件没更新成功，会停留在旧 commit，下次 `:Lazy update` 仍显示“有更新”，所以表现为“每次都超时 1–2 个”。
- 其余 ~60 个插件都能在几秒内正常完成。

## 二、环境与链路

```text
nvim 插件（remote 均为 git@github.com:user/repo.git）
  └─ SSH：~/.ssh/config 将 github.com 转到 ssh.github.com:443
       └─ ProxyCommand nc -x 127.0.0.1:7897   # 每进程独立新建一条隧道
            └─ 本地 Clash 代理（HTTP/SOCKS 混合端口 7897）
```

全局 git 配置有 `url.git@github.com:.insteadof=https://github.com/`，因此 lazy.nvim 按
默认 `git.url_format = "https://github.com/%s.git"` 生成的地址会被改写成 SSH，
所有插件 fetch 都走上面的 SSH → 代理隧道。

## 三、原因分析

lazy.nvim 默认选项（来源 `lazy.nvim/lua/lazy/core/config.lua`）：

```lua
concurrency = nil,            -- Linux 下并发数无上限
git = {
  timeout = 120,              -- 单条 git 进程超 120s 即被杀
  throttle = { enabled = false }, -- 网络操作不限速
  filter = true,              -- blob:none 部分克隆
}
```

### 根因：单点代理隧道被并发握手打满

1. `:Lazy update` 会对全部 ~60 个已装插件**同时**执行 `git fetch`
   （`concurrency = nil` + `throttle.enabled = false`，见 `task/git.lua` 的 `M.fetch`）。
2. 每个 fetch 都是一条**全新的 SSH 握手 + SOCKS 隧道**（`nc -x` 每次新建，无复用），
   单条正常约 3–4s。
3. ~60 条连接同时涌向同一个 Clash 节点 → 节点同时只能维持少量隧道，
   **排到队尾的连接迟迟无法完成握手**，超过 `git.timeout = 120` 即被杀 → “超时”。

结论：掉队的 1–2 个插件不是仓库本身有问题，而是**并发握手饿死**——单独 fetch 任意一个
都能在几秒内成功。

### 加重因素

- `git.filter = true`：blob:none 部分克隆下，变更大的仓库（如 SchemaStore 这类每天
  大规模更新的 JSON 库）在 checkout 时还要经同一条隧道下载缺失 blob，更易拖慢。
- `LuaSnip / yazi.nvim` 等带 submodule，fetch 用 `--recurse-submodules` 会连带拉子仓库。

### 复现与验证数据

| 测试 | 结果 |
|---|---|
| 65 路并发 `git fetch`（模拟 Lazy update） | yanky.nvim、mini.icons 100s 超时（rc=124） |
| 这两个插件单独 fetch | 各 ~3.5s 成功 → 纯属饿死 |
| 30 路并发 SSH，开启连接复用 | 全部 ~2.8s、总耗时 3.0s、零失败 |

## 四、解决办法（已应用）

### 1.（主修复）SSH 连接复用 —— `~/.ssh/config`

让并发的 git fetch **共享同一条隧道**，避免几十条独立握手涌向代理。

```sshconfig
Host github.com
  HostName ssh.github.com
  User git
  Port 443
  ProxyCommand nc -v -x 127.0.0.1:7897 %h %p
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
  UpdateHostKeys yes
  # 让并发的 git fetch 复用同一条隧道，避免 Lazy update 高并发时握手超时
  ControlMaster auto
  ControlPath ~/.ssh/cm-%C
  ControlPersist 600
  ServerAliveInterval 15
```

- 第一个连接做完整握手（~3s）后建立控制套接字，其余进程瞬时复用。
- `ControlPersist 600`：隧道保持 10 分钟，连续多次 `:Lazy update` 更快。
- 仅影响 SSH 通道，不改插件 remote / lock 文件 / nvim 配置。

验证：同样的 65 插件并发 fetch 探针，修复后 **0 超时，总耗时 ~7s**。

### 2.（保险）放宽 lazy git 超时 —— `lua/config/lazy.lua`

默认 `git.timeout = 120` 在慢代理下偶发误杀，放宽到 240s：

```lua
git = {
  -- 代理链路下并发 fetch 偶发较慢，默认 120s 易误杀，放宽到 240s
  timeout = 240,
},
```

### 3.（可选，未启用）限并发

若不想动 `~/.ssh/config`，可在 `lua/config/lazy.lua` 开启 lazy 自带的网络操作限速，
缺点是整体更新稍慢：

```lua
git = {
  throttle = { enabled = true, rate = 3, duration = 1000 }, -- 约每秒 3 条
  timeout = 240,
},
```

## 五、排查要点小结

1. 超时不等于仓库有问题：先单拉该插件验证（`git -C <dir> fetch`）。
2. 高并发 + 单代理 + 每次新握手 = 队尾饿死；开启 SSH `ControlMaster` 复用效果立竿见影。
3. `git.timeout` 只是兜底，真正的修复是降低/消除并发握手压力。
