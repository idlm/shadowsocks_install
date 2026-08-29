#!/usr/bin/env bash
# One-line installer for Shadowsocks (idlm-enhanced, libev+rust)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash
#   curl -fsSL ... | sudo bash -s -- --type libev --port 443 --auto
#
# This script downloads shadowsocks-all-enhanced.sh and runs it.
# You can also just `bash shadowsocks-all-enhanced.sh` directly after clone.
set -e

REPO="${SS_REPO:-idlm/shadowsocks_install}"
BRANCH="${SS_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}/idlm-enhanced/shadowsocks-all-enhanced.sh"

echo "[idlm-enhanced installer] Downloading shadowsocks-all-enhanced.sh ..."
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
echo "[idlm-enhanced installer] Running shadowsocks-all-enhanced.sh $@"
exec bash "$tmp" "$@"
