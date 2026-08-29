# teddysun/shadowsocks_install - 完整原版

这个目录是 [teddysun/shadowsocks_install](https://github.com/teddysun/shadowsocks_install)
仓库的完整 snapshot，**未做任何修改**。仅作参考对比。

## 文件清单

| 文件                            | 用途                                                         |
|---------------------------------|--------------------------------------------------------------|
| `shadowsocks-all.sh`            | **四合一**：libev / rust / v2ray-plugin / xray-plugin         |
| `shadowsocks-libev.sh`          | **单脚本**：仅 Shadowsocks-libev                              |
| `shadowsocks-libev-debian.sh`   | **单脚本**：libev + Debian repo (legacy)                      |
| `shadowsocks-go.sh`             | **单脚本**：仅 Shadowsocks-Go                                 |
| `shadowsocks.sh`                | **单脚本**：Shadowsocks-Python                                |
| `shadowsocksR`                  | ShadowsocksR 的 init.d 脚本（sysvinit）                       |
| `shadowsocksR-debian`           | ShadowsocksR init.d (debian fork)                             |
| `shadowsocks-debian`            | Shadowsocks-Python init.d                                     |
| `shadowsocks-go-debian`         | Shadowsocks-Go init.d                                         |
| `shadowsocks-libev-debian`      | Shadowsocks-libev init.d                                      |
| `shadowsocks-crond.sh`          | Shadowsocks 定时重启脚本                                     |
| `haproxy.sh`                    | HAProxy 一键安装（用于 ss 中转）                              |

## 已知兼容性问题

* **Debian 12+ 装包时 conffile 提示卡住**：原脚本没用 `--force-confdef --force-confnew`
* **Debian 12+ `update-rc.d` 被移除**：脚本里 `update-rc.d` 调用失败
* **Debian 11 上 Shadowsocks-Python 与 OpenSSL 1.1.1+ 不兼容**：会报
  `FileNotFoundError: b'liblibcrypto.a'`
* **`DynamicUser=true` 在 systemd 启动时导致 `Invalid config path`**：
  shadowsocks-libev 包默认 unit 用了 `DynamicUser=true`，但配置文件权限 600 nobody 读不到

## 改进版

请改用以下任一改进版：

* [`../idlm-enhanced/`](../idlm-enhanced/) — 保留 libev + rust，去掉 Python/SSR，apt 优先 + GitHub release 兜底
* [`../fmmx-enhanced/`](../fmmx-enhanced/) — 保留四版本，但 Python/SSR 已知不可用

## License

[MIT](https://github.com/teddysun/shadowsocks_install/blob/master/LICENSE) — Copyright (c) Teddysun
