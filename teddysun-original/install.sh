#!/usr/bin/env bash
# Original teddysun shadowsocks-all.sh installer
#
# This downloads and runs the **unmodified** teddysun 4-in-1 script.
# It is provided here for reference / comparison only.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/teddysun-original/install.sh | sudo bash
#
# For a Debian 12+ / Ubuntu 22.04+ compatible version, use idlm-enhanced/ instead.
set -e

REPO="${SS_REPO:-idlm/shadowsys_install}"
BRANCH="${SS_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}/teddysun-original/shadowsocks-all.sh"

echo "[teddysun-original] Downloading shadowsocks-all.sh ..."
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
if command -v curl >/dev/null; then
    curl --fail --location --retry 3 -o "$tmp" "$RAW"
elif command -v wget >/dev/null; then
    wget --no-check-certificate -c -t3 -T60 -O "$tmp" "$RAW"
else
    echo "Need curl or wget" >&2
    exit 1
fi

chmod +x "$tmp"
echo "[teddysun-original] Running shadowsocks-all.sh"
exec bash "$tmp"
