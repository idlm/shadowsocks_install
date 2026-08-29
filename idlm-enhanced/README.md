# Shadowsocks 一键安装脚本（idlm 增强版 - libev + rust）

> 在 [teddysun/shadowsocks_install](https://github.com/teddysun/shadowsocks_install)
> 基础上改造而来，去掉了已停止维护的 **Shadowsocks-Python** 和 **ShadowsocksR**，
> 保留 **Shadowsocks-libev** 和 **Shadowsocks-rust**，
> 并对 Debian 10/11/12/13、Ubuntu 20.04/22.04/24.04 全系做了兼容性加固。

## 一行安装（**默认交互**：会问端口、密码、加密方式）

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash
```

预填部分参数（**未指定的项会交互询问**）：

```bash
# 只指定 type，端口/密码/加密方式会被问到
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash -s -- --type libev

# 指定 type + 端口
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash -s -- --type libev --port 443

# 装 rust + v2ray 插件
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash -s -- --type rust --plugin v2ray
```

**在 `curl | bash` 场景下（无 TTY）必须预填所有需要的项**：

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh \
  | sudo bash -s -- --type libev --port 443 --password 'MyP@ss' \
                    --cipher chacha20-ietf-poly1305
```

或者直接 clone 后运行：

```bash
git clone https://github.com/idlm/shadowsocks_install.git
cd shadowsocks_install/idlm-enhanced
sudo bash shadowsocks-all-enhanced.sh
```

## 交互流程

启动后会依次询问：

1. **Type**：libev 或 rust（默认 libev）
2. **Port**：1-65535（默认随机）
3. **Password**：是否生成随机密码（推荐 Y），或自己输入
4. **Cipher**：列出可用加密方式，让用户选一个
5. **Plugin**（仅 rust）：none / v2ray-plugin / xray-plugin
6. **确认**最终配置

每个问题输入对应数字或直接回车接受默认。

## 用法

```text
Usage:
  sudo shadowsocks-all-enhanced.sh                              # fully interactive
  sudo shadowsocks-all-enhanced.sh install --type libev         # still asks for port / password / cipher
  sudo shadowsocks-all-enhanced.sh install --port 443           # still asks for type / password / cipher
  sudo shadowsocks-all-enhanced.sh uninstall

Options:
  install | uninstall        action (default: install)
  --type TYPE                libev | rust       (default: libev, still asked)
  --port PORT                1-65535            (asked if missing)
  --password PASSWORD        auth password      (asked if missing; default: random)
  --cipher CIPHER            stream cipher      (asked if missing; default: chacha20-ietf-poly1305)
  --plugin {none|v2ray|xray} SIP003 plugin      (asked if missing; rust only)
  -h, --help                 this help
```

## 支持的发行版

| 发行版              | libev  | rust | v2ray-plugin | xray-plugin |
|---------------------|:------:|:----:|:------------:|:-----------:|
| Debian 10 (buster)  | src    | bin  | bin          | bin         |
| Debian 11 (bullseye)| apt    | bin  | bin          | bin         |
| Debian 12 (bookworm)| apt    | apt  | apt          | apt         |
| Debian 13 (trixie)  | apt    | apt  | apt          | apt         |
| Ubuntu 20.04        | apt    | bin  | bin          | bin         |
| Ubuntu 22.04        | apt    | apt  | apt          | apt         |
| Ubuntu 24.04        | apt    | apt  | apt          | apt         |
| CentOS/RHEL 8+      | dnf    | dnf  | dnf          | dnf         |
| CentOS/RHEL 9+      | dnf    | dnf  | dnf          | dnf         |

* `apt` / `dnf` = 发行版官方包（首选，最快）
* `bin` = 从 GitHub release 直接下载预编译二进制
* `src` = 源码编译（仅当包管理器都拿不到时使用）

## 支持的加密方式

`aes-256-gcm`, `aes-192-gcm`, `aes-128-gcm`, `aes-256-cfb`, `aes-128-cfb`,
`aes-256-ctr`, `aes-192-ctr`, `aes-128-ctr`, `chacha20-ietf-poly1305`,
`chacha20-ietf`, `chacha20`, `xchacha20-ietf-poly1305`, `salsa20`, `rc4-md5`,
`2022-blake3-aes-256-gcm`, `2022-blake3-aes-128-gcm`,
`2022-blake3-chacha20-poly1305`（最后三个仅 rust 支持）

## 改进点（相对于 teddysun 原版）

1. **去掉了 Shadowsocks-Python / ShadowsocksR**：这俩早已 archived，会装出不可用的服务
2. **apt 探测**：装包前用 `apt-cache show` 检查包是否存在，缺包时清晰报错而不是静默失败
3. **GitHub release 兜底**：apt/dnf 没包时，从 GitHub 拉最新 release tarball/二进制
4. **默认交互**：端口/密码/加密方式/插件都会问，避免误选；可预填 `--port/--password/--cipher/--plugin` 跳过相应问题；`curl | bash` 场景下需要预填所有项
5. **随机密码**：默认用 `openssl rand` 生成 24 字符（原版硬编码 `teddysun.com`）
6. **systemd 单元探测**：区分发行版默认 unit 和自写 unit，Debian 12/13 行为不再有"Invalid config path"那种诡异错
7. **不写多余 `user` 字段**：探测容器/受限环境跑 root，避开 setgroups 失败
8. **stderr/stdout 分离**：进度走 stderr，结果走 stdout，方便 `tee` 记录日志
9. **workdir 自动清理**：用 `mktemp -d` + `trap`，不污染 `$(pwd)`
10. **`update-rc.d` 安全探测**：Debian 12+ 已移除，脚本会先 `command -v` 再调用
11. **QR PNG 存到 `/tmp/`**：原版存在 `$(pwd)`，跑完会留垃圾
12. **apt conffile 提示自动应答**：用 `--force-confdef --force-confnew`，auto 模式不会卡住

## 注意事项

1. **必须以 root 运行**：`sudo bash ...` 或 `su -c "bash ..."`
2. **脚本不修改防火墙**：装完后请手动开端口（firewalld / ufw / iptables / 云厂商安全组）
3. **Debian 12/13 推荐用 systemd 路径**：配置写到 `/etc/shadowsocks-libev/config.json`，
   跟发行版包默认路径一致
4. **容器/受限环境**（如 systemd-nspawn、LXC）：脚本会自动放弃降权到 `nobody`，
   服务以 root 启动，并通过 `AmbientCapabilities=CAP_NET_BIND_SERVICE` 限制权限
5. **OpenSSL 1.1.1+ / GCC 12+**：apt 优先路径已规避，源码兜底路径用 `libsodium-dev` /
   `libmbedtls-dev` 系统库
6. **服务端确认连接**：装完后用客户端连一下；shadowsocks 协议下，服务端不会回包，
   但端口 LISTEN 状态 + 客户端能连 = 成功

## 故障排查

| 现象                                  | 原因                                  | 解决                                  |
|---------------------------------------|---------------------------------------|---------------------------------------|
| `Invalid config path`                 | 发行版 systemd unit 含 `DynamicUser`   | 重新跑脚本，脚本会覆盖发行版 unit     |
| `EACCES` 读 config.json               | 权限 600 nobody 读不到                | 重新跑脚本，脚本会用 640              |
| `failed to switch user nobody`        | 容器无 setgroups 权限                 | 脚本会自动放弃降权，警告但不阻塞      |
| `dpkg` 卡 conffile 提示               | auto 模式没传 force 参数              | 已修，apt-get 已加 `--force-confdef`  |
| ss 客户端连不上                       | 防火墙/云厂商安全组没放行端口         | 自行开端口                            |
| `ss-server: invalid config format`    | config 用了 `server: [array]` 3.3.5 不支持 | 脚本默认 `"server":"0.0.0.0"`        |

完整修改说明见 [CHANGELOG.md](./CHANGELOG.md)。

## 致谢

* 原始脚本：[teddysun/shadowsocks_install](https://github.com/teddysun/shadowsocks_install)
* shadowsocks-libev：[shadowsocks/shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)
* shadowsocks-rust：[shadowsocks/shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
* v2ray-plugin：[teddysun/v2ray-plugin](https://github.com/teddysun/v2ray-plugin)
* xray-plugin：[teddysun/xray-plugin](https://github.com/teddysun/xray-plugin)

## License

MIT
