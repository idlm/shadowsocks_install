#!/usr/bin/env bash
# One-line installer for Shadowsocks (fmmx-enhanced, 4-in-1)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/fmmx-enhanced/install.sh | sudo bash
#
# Note: This script is interactive only. For non-interactive (CI/cloud-init)
# use idlm-enhanced/ instead.
set -e

REPO="${SS_REPO:-idlm/shadowsocks_install}"
BRANCH="${SS_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}/fmmx-enhanced/shadowsocks-libev-enhance.sh"

echo "[fmmx-enhanced installer] Downloading shadowsocks-libev-enhance.sh ..."
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
echo "[fmmx-enhanced installer] Running shadowsocks-libev-enhance.sh"
exec bash "$tmp"
