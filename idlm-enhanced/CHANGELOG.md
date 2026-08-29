# Changelog — shadowsocks-all-enhanced.sh

This file is a **patch-by-patch breakdown** of the changes applied to
[`teddysun/shadowsocks_install:shadowsocks-all.sh`](https://github.com/teddysun/shadowsocks_install/blob/master/shadowsocks-all.sh)
to produce `shadowsocks-all-enhanced.sh` (this repo).

The original upstream is preserved verbatim in
[`project原版/shadowsocks-all.sh`](./project原版/shadowsocks-all.sh) for
diff comparison.

Current version: **2.0.0-enhanced**

---

## 0. TL;DR — what changed at a glance

| # | Issue in upstream | Fix in enhanced | Lines |
|---|---|---|---|
| 1 | Hardcoded password `teddysun.com` | `openssl rand` -> 24 chars | ~270 |
| 2 | Only `read -p`; blocks in CI | Full `--port/--password/--cipher/--plugin` parsing | ~60-100 |
| 3 | `apt-get install` silent on miss | `apt_has_package` pre-check | ~165 / ~290 / ~430 |
| 4 | Service name `shadowsocks-libev-server` only works on the teddysun PPA | `service_unit_name()` picks per type, reuses distro unit | ~525-560 |
| 5 | No `systemctl is-enabled` check, so missing unit looks like install failure | Pre-check distro unit file, fail early | ~533-547 |
| 6 | `get_opsy` based on `awk` field guessing | Standard `source /etc/os-release` -> `os_pretty` | ~150 |
| 7 | Works on Debian 9/10/11 only (teddysun PPA gap) | Apt first, GitHub release fallback -> Debian 9-13 / Ubuntu 20-24 | ~310-370 / ~390-440 |
| 8 | No shadowsocks-rust fallback (had to be in repo) | Download latest binary from GitHub releases | ~395-435 |
| 9 | No v2ray/xray plugin fallback (repo only) | Download latest plugin binary from GitHub | ~450-485 |
| 10 | `ss-server` / `ssserver` paths hardcoded | `ExecStart=` set per type | ~570 |
| 11 | `get_char` uses `stty cbreak` -> breaks in non-TTY | `interactive_ask` only runs when `[ -t 0 ]` | ~275-310 |
| 12 | `set -o pipefail` missing | Added at top | 35 |
| 13 | `color` codes always printed | Disabled when stdout is not a TTY | 50-55 |
| 14 | `install_completed_*` always runs `clear` even with logs | Removed `clear`, sends summary to stderr | ~605 |
| 15 | Workdir left behind after install | `mktemp -d` + `trap rm -rf EXIT` | 220 / trap |
| 16 | `lsb_release` assumed to exist | Optional, only when actually adding the teddysun PPA; we don't add it | n/a |
| 17 | Only ports 9000-19999 suggested | `gen_port` picks 1024-65535 randomly | 200-205 |
| 18 | QR code saved in `$(pwd)` | Saved to `/tmp/` (no garbage in cwd) | ~600 |

---

## 1. Detailed patches

### 1.1 Robust option parsing (interactively-asked with pre-set values)

Upstream only accepted `install` / `uninstall` as a single positional
argument and read every other setting interactively. Enhanced keeps
the interactive behavior but lets the user pre-set values on the
command line to skip the corresponding prompt:

```text
--type      libev | rust                    (asked if missing)
--port      1-65535                          (asked if missing)
--password  text                             (asked if missing; default: random)
--cipher    chacha20-ietf-poly1305 | aes-256-gcm | ...   (asked if missing)
--plugin    none | v2ray | xray              (asked if missing; rust only)
```

When every value is pre-set, the script can be run from cloud-init,
Terraform, or a Dockerfile `RUN` line without a TTY:

```bash
./shadowsocks-all-enhanced.sh install \
    --type rust --port 443 --password 'MY_SECRET' \
    --cipher chacha20-ietf-poly1305
```

If you run via `curl | bash` (no TTY) without pre-setting all values,
the script refuses to start with a clear error message instead of
silently picking random defaults.

### 1.2 Random password by default

Upstream defaulted to the literal `teddysun.com`. Enhanced uses
`openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 24`, which gives
~143 bits of entropy from a 62-char alphabet. The password is still
printed at the end of the install so the operator can copy it.

### 1.3 apt repository probing

Upstream assumes the teddysun PPA is configured. Enhanced detects
whether the package is available before trying to install:

```bash
apt_has_package() { apt-cache show "$1" >/dev/null 2>&1; }
```

This is critical for **Debian 10 (buster)** and **Ubuntu 20.04** where
the teddysun PPA is sometimes slow to be updated. If the distro repo
has the package, we use that. If not, we fall back to GitHub releases.

### 1.4 GitHub release fallback

If neither apt nor dnf has the desired package, enhanced downloads the
latest release directly from GitHub:

| Component     | Upstream repo                                |
|---------------|----------------------------------------------|
| shadowsocks-libev | `shadowsocks/shadowsocks-libev`          |
| shadowsocks-rust  | `shadowsocks/shadowsocks-rust`           |
| v2ray-plugin      | `teddysun/v2ray-plugin`                 |
| xray-plugin       | `teddysun/xray-plugin`                  |

The arch mapping is explicit:

| `uname -m` | `shadowsocks-rust` arch           | plugin arch |
|------------|-----------------------------------|-------------|
| x86_64     | x86_64-unknown-linux-gnu          | amd64       |
| aarch64    | aarch64-unknown-linux-gnu         | arm64-v8a   |
| armv7l     | armv7-unknown-linux-gnueabihf     | armv7       |

This means the script works on **arm64** VPS providers (Oracle, Hetzner,
Scaleway) where the teddysun PPA may not have aarch64 builds.

### 1.5 Distro-package systemd units

Upstream writes `/etc/systemd/system/shadowsocks-libev-server.service`
unconditionally. On Debian 12+/Ubuntu 22.04+ the official package already
installs `/lib/systemd/system/shadowsocks-libev.service`, so the
hand-written unit would *shadow* the upstream unit. Enhanced now
detects which units exist and only writes its own if the package is
absent:

```bash
start_service() {
    local svc; svc=$(service_unit_name)
    if [ -f "/etc/systemd/system/${svc}" ] \
       || [ -f "/lib/systemd/system/${svc}" ] \
       || [ -f "/usr/lib/systemd/system/${svc}" ]; then
        systemctl daemon-reload
        systemctl enable  "$svc" >/dev/null
        systemctl restart "$svc"
    else
        log_warn "No distro unit found, the package install may have failed"
        return 1
    fi
}
```

### 1.6 shadowsocks-rust + SIP003 plugin

Upstream supported `v2ray-plugin` and `xray-plugin` only if the teddysun
repo was enabled. Enhanced:

* Calls `apt-get install shadowsocks-rust` directly (works on Debian 12+,
  Ubuntu 22.04+ where it's in main)
* On older systems, downloads the latest release tarball
  (no compiler needed)
* Same pattern for `v2ray-plugin` / `xray-plugin`

### 1.7 Clean working directory

Upstream accumulates `mbedtls-*` / `libsodium-*` / `shadowsocks-*.tar.gz`
in `$(pwd)`. Enhanced uses `mktemp -d` plus `trap rm -rf EXIT`, so
nothing is left behind.

### 1.8 stderr/stdout split

Upstream prints everything to stdout, including the QR code. Enhanced
sends progress to stderr so `script.sh 2>progress.log` is possible, and
only the final QR code goes to stdout. The colors are also disabled
when stdout is not a TTY (so `cat install.log` is clean).

### 1.9 Default mode is interactive

Removed the `--auto` flag entirely. The user is always asked for type,
port, password, cipher and (for rust) plugin, even if a value was passed
on the command line — the value is shown in brackets and the user can
press Enter to accept it or type a new one. To run non-interactively
(e.g. from `curl | bash`), pre-set every value with --port/--password/
--cipher. The script refuses to start with a clear error if invoked
without a TTY and without those values, instead of silently picking
random defaults.### 1.10 Firewall

Upstream handled `firewalld` and `ufw` separately. Enhanced
consolidated both into a single `config_firewall` that detects which is
active.

---

## 2. Compatibility matrix (after this fork)

| Distro                  | libev  | rust | v2ray-plugin | xray-plugin |
|-------------------------|--------|------|--------------|-------------|
| Debian 10 (buster)      | src    | bin  | bin          | bin         |
| Debian 11 (bullseye)    | src/apt| bin  | bin          | bin         |
| Debian 12 (bookworm)    | apt    | apt  | apt          | apt         |
| Debian 13 (trixie)      | apt    | apt  | apt          | apt         |
| Ubuntu 20.04            | src/apt| bin  | bin          | bin         |
| Ubuntu 22.04            | apt    | apt  | apt          | apt         |
| Ubuntu 24.04            | apt    | apt  | apt          | apt         |
| CentOS/RHEL 8+          | dnf    | dnf  | dnf          | dnf         |
| CentOS/RHEL 9+          | dnf    | dnf  | dnf          | dnf         |

* `apt` = official distro package
* `dnf` = official distro package
* `src` = build from source (only if package is missing)
* `bin` = download from GitHub release

---

## 3. Things upstream does that we keep

* `disable_selinux()` (still useful for RHEL)
* `qrencode` PNG output (now goes to `/tmp/` instead of cwd)
* SIP003 QR code format with plugin encoding
* Compatibility with both Debian- and RHEL-family distros

---

## 4. Known limitations (kept on purpose)

* No IPv6-only server yet (config has `["::0","0.0.0.0"]` already)
* `simple-obfs` plugin is not in the official Debian repo; install it
  manually if needed (`apt install shadowsocks-libev` already pulls it
  on Debian 12+)
* Plugin options are not auto-validated; you can pass anything
  `v2ray-plugin` / `xray-plugin` accepts
