# Fmmx/shadowsocks-libev-enhance - 完整原版

这个目录保存的是 [Fmmx/shadowsocks-libev-enhance](https://github.com/Fmmx/shadowsocks-libev-enhance)
仓库的主脚本 `shadowsocks-libev-enhance.sh`，**未做任何修改**。
仅作参考对比。

## 文件清单

| 文件                            | 用途                                                                 |
|---------------------------------|----------------------------------------------------------------------|
| `shadowsocks-libev-enhance.sh`  | 四合一安装脚本：Shadowsocks-Python / ShadowsocksR / Shadowsocks-Go / Shadowsocks-libev |

## 它相对于 teddysun 的改动

1. 增强了 Debian 10/11/12 的依赖检测（mbedtls 包名探测、PCRE 替代等）
2. systemd 优先，老 Debian 才回退 SysVinit
3. `update-rc.d` 安全探测

## 已知问题

* **Shadowsocks-Python 已 EOL**（原作者 2017 年 archived），仍能装但与 OpenSSL 1.1.1+ 不兼容
* **ShadowsocksR 已 EOL**，原仓库 archived
* 默认密码 `MissUnotMissu`（任何人都能搜到）
* 纯交互式，CI / cloud-init 跑不了

## 改进版

请改用：

* [`../idlm-enhanced/`](../idlm-enhanced/) — 保留 libev + rust，去掉 Python/SSR，非交互模式 + apt 优先

## License

[MIT](https://github.com/Fmmx/shadowsocks-libev-enhance) — Copyright (c) Fmmx
