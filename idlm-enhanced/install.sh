#!/usr/bin/env bash
# One-line installer for Shadowsocks (idlm-enhanced, libev+rust)
#
# By default the main script is **interactive**: it will ask the user for
# port, password, cipher and plugin. You can pre-set some of these on
# the command line (see shadowsocks-all-enhanced.sh --help).
#
# When invoked via `curl | bash` (no TTY) you MUST pre-set every value
# or the script will refuse to run.
#
# Usage:
#   # Interactive (TTY required):
#   curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh | sudo bash
#
#   # Pre-set everything (works without TTY):
#   curl -fsSL https://raw.githubusercontent.com/idlm/shadowsocks_install/main/idlm-enhanced/install.sh \
#     | sudo bash -s -- --type libev --port 443 --password 'MyP@ss' --cipher chacha20-ietf-poly1305
#
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
