# idlm-enhanced 使用说明（卸载安装 / 文件清单）

> 适用于 `idlm-enhanced/shadowsocks-all-enhanced.sh` 的所有运行场景。
> 上游仓库：<https://github.com/idlm/shadowsocks_install>（idlm 分支）。

## 目录

1. [一键安装](#一-一键安装)
2. [交互式 vs 自动模式](#二-交互式-vs-自动模式)
3. [所有可调参数](#三-所有可调参数)
4. [支持的加密方式](#四-支持的加密方式)
5. [支持的发行版](#五-支持的发行版)
6. [一键卸载](#六-一键卸载)
7. [安装和卸载涉及的文件](#七-安装和卸载涉及的文件)
8. [故障排查](#八-故障排查)

---

## 一、一键安装

### 1. 默认（交互式）

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash
```

打开后按提示选择：type / port / password / cipher / plugin。

### 2. 加 `--auto`（完全自动）

```bash
# 随机端口 + 随机密码 + 默认 aes-256-gcm
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash -s -- --auto
```

### 3. 预填部分参数（最常见）

```bash
# 指定端口 443，其余仍然交互询问
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash -s -- --port 443
```

### 4. 完全预填（CI / cloud-init）

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh \
  | sudo bash -s -- --type libev --port 443 --password 'MyP@ss' --cipher aes-256-gcm
```

### 5. 不用 curl，本地 clone 后跑

```bash
git clone https://github.com/idlm/shadowsocks_install.git
cd shadowsocks_install/idlm-enhanced
sudo bash shadowsocks-all-enhanced.sh
```

---

## 二、交互式 vs 自动模式

| 模式 | 触发 | 行为 |
|------|------|------|
| 交互式 | TTY 终端，无 `--auto` | 依次问 type/port/password/cipher/plugin |
| 自动 | 传 `--auto` / `-y` | 跳过所有问题；未指定的项用默认值（随机端口/随机密码/aes-256-gcm/无插件） |
| 自动（自动启用） | `curl \| bash` 时**没有** `--auto` | 脚本自动启用 auto 模式，提示 `No TTY detected`，不报错 |

> 重要：在 `curl | sudo bash` 这种"管道 + sudo"场景下，stdin 是 pipe（不是 tty），
> 脚本会**自动**降级为 auto 模式，不会卡住也不会报错。

---

## 三、所有可调参数

```text
Usage: shadowsocks-all-enhanced.sh [install|uninstall] [options]

Options:
  --type TYPE                libev | rust                (default: libev)
  --port PORT                1-65535
  --password PASSWORD        auth password                (default: random 24 chars)
  --cipher CIPHER            stream cipher                (default: aes-256-gcm)
  --plugin {none|v2ray|xray} SIP003 plugin                (default: none; rust only)
  --auto, -y                 skip all prompts
  -h, --help                 this help
```

### 例子

| 命令 | 行为 |
|------|------|
| `bash shadowsocks-all-enhanced.sh` | 走交互（TTY） |
| `bash shadowsocks-all-enhanced.sh --auto` | 跳过一切 |
| `bash shadowsocks-all-enhanced.sh --port 443` | TTY 模式：只预填端口，其余还是问 |
| `bash shadowsocks-all-enhanced.sh --port 443 --auto` | 用 443 + 随机密码 |
| `bash shadowsocks-all-enhanced.sh --type rust --plugin v2ray` | TTY 模式：装 rust + v2ray plugin |
| `bash shadowsocks-all-enhanced.sh uninstall` | 卸载 libev |
| `bash shadowsocks-all-enhanced.sh uninstall --type rust` | 卸载 rust |

---

## 四、支持的加密方式

**默认 = `aes-256-gcm`（强加密）**

### libev 支持

| 加密方式 | 推荐 | 备注 |
|----------|:----:|------|
| `aes-256-gcm` | ✅ | **默认**；AEAD，主流选择 |
| `aes-128-gcm` | ✅ | 略弱于 256，但性能更高 |
| `chacha20-ietf-poly1305` | ✅ | 移动设备首选（无 AES 加速） |
| `xchacha20-ietf-poly1305` | ✅ | chacha20 的扩展版，更长 nonce |
| `chacha20-ietf` | ⚠️ | 不带 poly1305 认证，**不推荐** |
| `aes-256-ctr` | ⚠️ | 不带认证，**不推荐** |

### rust 多支持 3 个 AEAD-2022

* `2022-blake3-aes-256-gcm`
* `2022-blake3-aes-128-gcm`
* `2022-blake3-chacha20-poly1305`

> 完整列表参考 `shadowsocks-all-enhanced.sh --help` 的 Options 段。

---

## 五、支持发行版

| 发行版 | libev 来源 | rust 来源 |
|--------|------------|-----------|
| Debian 10 (buster) | 源码编译 | GitHub release |
| Debian 11 (bullseye) | apt 官方包 | GitHub release |
| Debian 12 (bookworm) | apt 官方包 | apt 官方包 |
| Debian 13 (trixie) | apt 官方包 | apt 官方包 |
| Ubuntu 20.04 | apt 官方包 | GitHub release |
| Ubuntu 22.04 | apt 官方包 | apt 官方包 |
| Ubuntu 24.04 | apt 官方包 | apt 官方包 |
| CentOS 8 / RHEL 8 | dnf 官方包 | dnf 官方包 |
| CentOS 9 / RHEL 9 | dnf 官方包 | dnf 官方包 |

apt 优先 → GitHub release 兜底 → 源码编译（最后才用）。

---

## 六、一键卸载

```bash
# 卸载 libev（默认）
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh \
  | sudo bash -s -- uninstall

# 卸载 rust
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh \
  | sudo bash -s -- uninstall --type rust
```

或者本地：

```bash
cd shadowsocks_install/idlm-enhanced
sudo bash shadowsocks-all-enhanced.sh uninstall
sudo bash shadowsocks-all-enhanced.sh uninstall --type rust
```

卸载前**不需要**手动停止服务，脚本会自己 `systemctl stop`。

---

## 七、安装和卸载涉及的文件

### 安装时创建/修改的文件

| 路径 | 创建者 | 说明 |
|------|--------|------|
| `/etc/shadowsocks-libev/config.json` | libev 安装 | ss-server 配置文件（libev） |
| `/etc/shadowsocks-libev/` | libev 安装 | 整个配置目录 |
| `/etc/shadowsocks/shadowsocks-rust-config.json` | rust 安装 | ssserver 配置文件（rust） |
| `/etc/systemd/system/shadowsocks-libev.service` | 脚本 | systemd 单元（libev） |
| `/etc/systemd/system/shadowsocks-rust.service` | 脚本 | systemd 单元（rust） |
| `/var/log/shadowsocks-libev.log` | ss-server | 日志（libev） |
| `/var/log/shadowsocks-rust.log` | ssserver | 日志（rust） |
| `/usr/bin/ss-server` | apt / 源码 | 可执行文件（libev） |
| `/usr/bin/ssserver` | apt / 源码 | 可执行文件（rust） |
| `/tmp/shadowsocks_libev_qr.png` | 脚本 | QR 码图片（libev） |
| `/tmp/shadowsocks_rust_qr.png` | 脚本 | QR 码图片（rust） |

### apt 装包可能装这些（取决于发行版）

* `shadowsocks-libev` （libev 主体）
* `libmbedtls-dev` / `libmbedtls14` （mbedtls 库）
* `libsodium-dev` / `libsodium23` （libsodium 库）
* `libc-ares2` / `libc-ares-dev` （c-ares 库）
* `libev4` / `libev-dev` （libev 库）
* `shadowsocks-rust` （rust 主体，仅 Debian 12+ / Ubuntu 22.04+）

### 卸载时清理

| 路径 | 行为 |
|------|------|
| `/etc/systemd/system/shadowsocks-libev.service` | 删除 |
| `/etc/systemd/system/shadowsocks-rust.service` | 删除 |
| `/etc/shadowsocks-libev/config.json` | 删除 |
| `/etc/shadowsocks-libev/` | 整个目录删除 |
| `/etc/shadowsocks/shadowsocks-rust-config.json` | 删除 |
| `/var/log/shadowsocks-libev.log` | 删除 |
| `/var/log/shadowsocks-rust.log` | 删除 |
| `/usr/bin/ss-server` / `/usr/local/bin/ss-server` | 保留（apt 装的，从源卸载时自动删） |
| `/usr/bin/ssserver` / `/usr/local/bin/ssserver` | 保留（同上） |

**apt 包** 用 `apt-get remove` 卸；**源码装的二进制** 用 `rm` 删。
卸载脚本**只**清理上面列出的文件，**不**动以下目录：

* `/etc/skel/`、`/home/*/`
* 用户的 systemd 单元（`/etc/systemd/system/<user>.service`）
* 用户的 crontab（如果有 `shadowsocks-crond` 残留）

### 本仓库内的文件

| 文件 | 用途 |
|------|------|
| `shadowsocks-all-enhanced.sh` | 主安装/卸载脚本（你要运行的那个） |
| `install.sh` | 一行安装入口（`curl ... \| sudo bash`） |
| `README.md` | 项目级 README |
| `CHANGELOG.md` | 改进点清单 |

`install.sh` 只是个 wrapper，做两件事：
1. 从 GitHub raw 下载 `shadowsocks-all-enhanced.sh` 到 `/tmp`
2. `exec bash /tmp/shadowsocks-all-enhanced.sh "$@"` 执行

所以你**完全可以** `wget` 主脚本直接用：

```bash
wget -O shadowsocks-all-enhanced.sh \
  https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/shadowsocks-all-enhanced.sh
chmod +x shadowsocks-all-enhanced.sh
sudo ./shadowsocks-all-enhanced.sh
```

---

## 八、故障排查

### A. `curl | sudo bash` 报 `Interactive mode requires a TTY`

**原因**：你的 `sudo` 配置强制要求 tty（`Defaults requiretty`），导致 `[ -t 0 ]` 返回 true 但实际 stdin 不可读。

**解决**：
1. 升级到最新脚本（已修复，会自动降级为 auto 模式）
2. 或显式加 `--auto`：
   ```bash
   curl -fsSL .../install.sh | sudo bash -s -- --auto
   ```

### B. 装完客户端连不上

1. 检查服务在跑：
   ```bash
   systemctl status shadowsocks-libev
   ss -tunlp | grep <端口>
   ```
2. 检查防火墙 / 云厂商安全组是否放行了端口
3. 检查密码、加密、端口是否一致

### C. dpkg 报 `dpkg: error processing package shadowsocks-libev`

多数情况是 `apt-get update` 时上游 conffile 提示。**已自动用 `--force-confdef --force-confnew` 解决**，无影响。

### D. 卸载时找不到某个包

新代码只 `apt remove` 已装的包（`dpkg -l | grep ^ii` 检查），不会再输出 `E: Unable to locate package`。

### E. 卸载完服务还在跑

1. `systemctl status shadowsocks-libev` 确认
2. 如果还 active：
   ```bash
   sudo systemctl stop shadowsocks-libev
   sudo systemctl disable shadowsocks-libev
   ```
3. 手动清理残留：
   ```bash
   sudo rm -f /etc/systemd/system/shadowsocks-libev.service
   sudo rm -rf /etc/shadowsocks-libev
   ```

### F. 已知问题（仅作参考）

* **Fmmx 增强版** 和 **teddysun 原版** 的 `uninstall` 在用户没选版本号时会**死循环**要 Ctrl+C。这是原版 bug，本仓库未修复。

---

## 附录：完整命令参考

```bash
# === 安装 ===

# 交互式
sudo bash shadowsocks-all-enhanced.sh

# 自动模式
sudo bash shadowsocks-all-enhanced.sh --auto

# 装 libev，指定端口 + 随机密码
sudo bash shadowsocks-all-enhanced.sh --type libev --port 443 --auto

# 装 rust + v2ray 插件
sudo bash shadowsocks-all-enhanced.sh --type rust --plugin v2ray --auto

# 装 rust + xray 插件
sudo bash shadowsocks-all-enhanced.sh --type rust --plugin xray --auto

# 装 libev，指定端口 + 密码 + 加密
sudo bash shadowsocks-all-enhanced.sh --port 443 --password 'MyP@ss' --cipher aes-256-gcm

# 通过 curl 一行
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash
curl -fsSL ... | sudo bash -s -- --auto
curl -fsSL ... | sudo bash -s -- --type libev --port 443 --auto

# === 卸载 ===

sudo bash shadowsocks-all-enhanced.sh uninstall                    # libev (default)
sudo bash shadowsocks-all-enhanced.sh uninstall --type rust         # rust
curl -fsSL ... | sudo bash -s -- uninstall
```

---

## License

MIT
