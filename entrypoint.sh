#!/bin/bash
set -e

log() {
  echo "[ENTRYPOINT] $(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a /config/logs/entrypoint.log
}

log "Starting SABnzbd container setup..."

for dir in /downloads /downloads/complete /downloads/incomplete /downloads/intermediate /scripts /config /config/logs; do
  mkdir -p "$dir"
  log "Ensured directory: $dir"
done

touch /config/logs/sabnzbd.log /config/logs/entrypoint.log
chown nobody:users /config/logs/*.log || true
chmod 644 /config/logs/*.log || true

log "Initializing logrotate..."
/usr/local/bin/logrotate-launch.sh

log "Launching SABnzbd from /opt/sabnzbd"
exec python3 /opt/sabnzbd/SABnzbd.py --server 0.0.0.0:8080 --config-file /config/sabnzbd.ini