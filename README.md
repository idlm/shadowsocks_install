# Shadowsocks 一键安装脚本集合

> **三个版本的 shadowsocks 一键安装脚本** 集中在一个仓库：
> teddysun 原版（archive） / Fmmx 增强版（4-in-1） / idlm 增强版（2-in-1）.
>
> 已在 **Debian 10/11/12/13、Ubuntu 20.04/22.04/24.04、CentOS/RHEL 8+** 上验证。

## 🚀 一键安装命令

按你的需求**单独复制**其中一条即可：

### 1. idlm 增强版（2-in-1，libev + rust） — 推荐

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash
```

或者非交互式（装 libev，端口 443，密码随机）：

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash -s -- --type libev --port 443 --auto
```

### 2. Fmmx 增强版（4-in-1，Python/R/Go/libev）

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/fmmx-enhanced/install.sh | sudo bash
```

### 3. teddysun 原版（仅参考）

```bash
curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/teddysun-original/install.sh | sudo bash
```

## 选哪个？

| 场景                                          | 推荐目录 | 脚本                                |
|-----------------------------------------------|----------|-------------------------------------|
| 只想装个 ss 服务                              | **idlm-enhanced** | `shadowsocks-all-enhanced.sh` |
| 客户端是普通 SS（Win/macOS/iOS/Android）      | **idlm-enhanced libev** | `shadowsocks-all-enhanced.sh` |
| 客户端支持 SIP003 插件 / 想要 V2Ray/Xray 混淆 | **idlm-enhanced rust** | `shadowsocks-all-enhanced.sh` |
| 需要兼容老 SSR 客户端 / Python 版（不推荐）   | fmmx-enhanced | `shadowsocks-libev-enhance.sh` |
| 只想看原版做对比 / 研究                       | teddysun-original | `shadowsocks-all.sh` 等  |

**绝大多数用户**：直接用 `idlm-enhanced/` 的 libev。

## 目录结构

```
shadowsocks_install/
├── README.md                              ← 本文件
├── LICENSE                                MIT
├── .github/
│   └── workflows/
│       └── shellcheck.yml                 GitHub Actions: shellcheck 自动检查
│
├── idlm-enhanced/                         ⭐ 推荐
│   ├── README.md
│   ├── install.sh                         一行安装入口
│   ├── shadowsocks-all-enhanced.sh        主脚本（libev+rust，766 行）
│   └── CHANGELOG.md                       12 个改进点
│
├── fmmx-enhanced/                         (4-in-1：Python/R/Go/libev；Python/SSR 不可用)
│   ├── README.md
│   ├── install.sh                         一行安装入口
│   └── shadowsocks-libev-enhance.sh       主脚本（Python/R/Go/libev，1548 行）
│
└── teddysun-original/                     完整原版存档（仅参考）
    ├── README.md
    ├── shadowsocks-all.sh                 四合一原版
    ├── shadowsocks-libev.sh               单脚本原版
    ├── shadowsocks-go.sh
    ├── shadowsocks.sh                     Python 原版
    ├── haproxy.sh                         HAProxy 中转
    ├── shadowsocks-crond.sh               定时重启
    └── *.debain, *-debian                 init.d 脚本
```

## 已验证兼容的发行版

| 发行版              | libev (idlm)    | rust (idlm)     | python (fmmx)           | Go (fmmx)     |
|---------------------|:---------------:|:---------------:|:-----------------------:|:-------------:|
| Debian 10 (buster)  | ✅ 源码         | ✅ 二进制        | ❌ 不可用（见下）       | ✅ 二进制     |
| Debian 11 (bullseye)| ✅ apt          | ✅ 二进制        | ❌ 不可用（见下）       | ✅ 二进制     |
| Debian 12 (bookworm)| ✅ apt          | ✅ apt           | ❌ 不可用（见下）       | ✅ apt        |
| Debian 13 (trixie)  | ✅ apt          | ✅ apt           | ❌ 不可用（见下）       | ✅ apt        |
| Ubuntu 20.04        | ✅ apt          | ✅ 二进制        | ❌ 不可用（见下）       | ✅ apt        |
| Ubuntu 22.04        | ✅ apt          | ✅ apt           | ❌ 不可用（见下）       | ✅ apt        |
| Ubuntu 24.04        | ✅ apt          | ✅ apt           | ❌ 不可用（见下）       | ✅ apt        |
| CentOS 8 / RHEL 8   | ✅ dnf          | ✅ dnf           | ❌ 不可用（见下）       | ✅ dnf        |
| CentOS 9 / RHEL 9   | ✅ dnf          | ✅ dnf           | ❌ 不可用（见下）       | ✅ dnf        |

### 图例

| 标记         | 含义                                                       |
|--------------|------------------------------------------------------------|
| ✅ 源码      | 发行版无包，脚本自动源码编译                               |
| ✅ apt       | 发行版官方包可用                                           |
| ✅ dnf       | CentOS/RHEL 官方包可用                                     |
| ✅ 二进制    | 脚本从 GitHub release 拉预编译二进制                       |
| ❌ 不可用    | 即使脚本能装，服务也启不来（依赖不存在或原作者已废弃）     |

### 为什么 Python 版不可用

**Shadowsocks-Python** 在 2017 年被原作者
[clowwindy](https://github.com/clowwindy) archived，仓库已不再维护。具体问题：

1. **OpenSSL 1.1.1+ 不兼容**：代码硬编码找 `libcrypto.a`（OpenSSL 1.0.x 时代的静态库名）
   * Debian 11 的 `libssl-dev` 不再提供 `libcrypto.a`
   * 启动时 ssserver 会抛 `FileNotFoundError: b'liblibcrypto.a'`
2. **Python 3.12+ 语法错误**：`is ""` / `is not 0` 写法在 3.12+ 报 SyntaxError
3. **没有 IPv6 server 数组支持**：`server: [array]` 写法在 3.0.0 也不支持

→ **建议改用 libev 或 rust 版**，协议完全兼容。

### 关于 Go 版

**Shadowsocks-Go** 仍是活跃项目，
[database64128/shadowsocks-go](https://github.com/database64128/shadowsocks-go) 有新维护分支。
原 teddysun 仓库里的 `shadowsocks-go` 是 1.2.2 版本（2015），功能上够用但不推荐新部署。

## 主要特性（idlm 增强版）

* **apt 优先**：发行版官方包能用就用，速度快、签名验证过
* **GitHub release 兜底**：包管理器拿不到时从 GitHub 拉预编译二进制
* **源码兜底**：最后才编译源码，避免耗时 build
* **systemd 单元自带**：脚本生成的 unit 不带 `DynamicUser`，
  规避 Debian 11 / 12 上的 "Invalid config path" bug
* **非交互模式**：`--auto --port --password --cipher --plugin`
  全套参数，CI / cloud-init 友好
* **随机密码**：默认 `openssl rand` 生成 24 字符
* **自动适配容器/受限环境**：探测 `setgroups` 权限，失败时不降权到 nobody

## 注意事项

1. **必须以 root 运行**：`sudo bash ...`
2. **Debian 12+ 已无 SysVinit**：脚本自动用 systemd，不需要手动处理
3. **OpenSSL 1.1.1+ / GCC 12+ 兼容**：apt 优先路径已规避，源码兜底路径用系统库
4. **防火墙/安全组**：脚本**不**自动改防火墙，装完请手动开端口
5. **服务端验证**：装完用 `ss -tunlp | grep <port>` 看端口 LISTEN 状态；
   shadowsocks 协议下服务端不会主动回包，端口 LISTEN = 成功
6. **不建议用 Python 版**：原作者 2017 年 archived，与 OpenSSL 1.1.1+ 不兼容
7. **不建议用 SSR**：原作者 2017 年 archived，且需要专门客户端
8. **本仓库所有脚本仅供学习与个人使用**，请遵守当地法规

## 故障排查

请先看对应子目录的 README：

* [idlm-enhanced/故障排查](./idlm-enhanced/README.md#故障排查)
* [fmmx-enhanced/已知问题](./fmmx-enhanced/README.md#已知问题)
* [teddysun-original/已知兼容性问题](./teddysun-original/README.md#已知兼容性问题)

## 贡献

* 报告 bug：开 [Issue](https://github.com/idlm/shadowsocks_install/issues)
* 提 PR：fork + pull request 即可
* 跑测试：装上 [shellcheck](https://www.shellcheck.net/) 后跑
  `shellcheck idlm-enhanced/shadowsocks-all-enhanced.sh`

## 上游致谢

* teddysun：[teddysun/shadowsocks_install](https://github.com/teddysun/shadowsocks_install)
* Fmmx：[Fmmx/shadowsocks-libev-enhance](https://github.com/Fmmx/shadowsocks-libev-enhance)
* shadowsocks-libev：[shadowsocks/shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)
* shadowsocks-rust：[shadowsocks/shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
* v2ray-plugin：[teddysun/v2ray-plugin](https://github.com/teddysun/v2ray-plugin)
* xray-plugin：[teddysun/xray-plugin](https://github.com/teddysun/xray-plugin)

## License

MIT
