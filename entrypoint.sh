#!/bin/bash

set -e

echo "======================================"
echo " Free Proxy"
echo "======================================"

echo "[INFO] Checking TUN..."

if [ ! -e /dev/net/tun ]; then
    echo "[ERROR] /dev/net/tun 不存在"
    echo "[ERROR] 请确认 Docker 使用了:"
    echo "        --device=/dev/net/tun:/dev/net/tun"
    exit 1
fi

echo "[OK] TUN available"

echo "[INFO] Checking OpenVPN..."

if ! command -v openvpn >/dev/null 2>&1; then
    echo "[ERROR] OpenVPN 未安装"
    exit 1
fi

echo "[OK] OpenVPN available"

echo "[INFO] Starting free-proxy..."

exec /usr/local/bin/free-proxy serve
