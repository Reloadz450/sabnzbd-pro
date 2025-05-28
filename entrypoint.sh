#!/bin/bash
set -e

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

echo "[ENTRYPOINT] $(timestamp) - Starting SABnzbd container setup..."

mkdir -p /downloads /downloads/complete /downloads/incomplete /downloads/intermediate
mkdir -p /scripts /config /config/logs

touch /config/sabnzbd.ini
chmod 666 /config/sabnzbd.ini

echo "[ENTRYPOINT] $(timestamp) - Checking binaries..."
echo "[ENTRYPOINT] par2: $(/usr/local/bin/par2 -V || echo 'not found')"
echo "[ENTRYPOINT] unrar: $(/usr/local/bin/unrar | head -n 1 || echo 'not found')"
echo "[ENTRYPOINT] Starting SABnzbd using direct script invocation..."

exec python3 /opt/sabnzbd/SABnzbd.py --console --server 0.0.0.0:8080 --config-file /config/sabnzbd.ini
