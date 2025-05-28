#!/bin/bash
set -e

LOG_DIR="/config/logs"
LOG_FILE="$LOG_DIR/sabnzbd.log"
ENTRYPOINT_LOG="$LOG_DIR/entrypoint.log"
ROTATE_CONF="/etc/logrotate.d/sabnzbd"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE" "$ENTRYPOINT_LOG"
chown nobody:users "$LOG_FILE" "$ENTRYPOINT_LOG"
chmod 644 "$LOG_FILE" "$ENTRYPOINT_LOG"

cat <<EOF > "$ROTATE_CONF"
$LOG_FILE {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 644 nobody users
    dateext
    dateformat -%Y%m%d
    postrotate
        pkill -HUP -f SABnzbd.py || true
    endscript
}
EOF

if [[ "${LOGROTATE_VERBOSE:-false}" == "true" ]]; then
    echo "[logrotate] Running in verbose mode..." | tee -a "$ENTRYPOINT_LOG"
    /usr/sbin/logrotate -v "$ROTATE_CONF" | tee -a "$LOG_FILE" | tee -a "$ENTRYPOINT_LOG"
else
    echo "[logrotate] Running silently..." >> "$ENTRYPOINT_LOG"
    /usr/sbin/logrotate "$ROTATE_CONF" >> "$LOG_FILE" 2>&1
fi