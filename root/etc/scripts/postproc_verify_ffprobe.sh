#!/bin/bash
# sabnzbd-postproc.sh
# Robust post-processing script for SABnzbd containers (Reloadz450/sabnzbd-pro)
# Performs multi-threaded unpacking, ffprobe validation, and auto-purges malformed video jobs

# Requirements: ffprobe, pigz, par2, jq (all included in the container)

# Directory where SAB sends the download (provided as argument 1)
DEST_DIR="$1"
LOG_FILE="/data/sabnzbd_postproc.log"
BROKEN_LOG="/data/broken_downloads.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

scan_and_validate() {
    local file="$1"
    if ffprobe -v error "$file" > /dev/null 2>&1; then
        log "✓ VALID: $file"
    else
        log "✗ MALFORMED: $file"
        echo "$file" >> "$BROKEN_LOG"
        rm -fv "$file"
        rmdir -v "$(dirname "$file")" 2>/dev/null
    fi
}

# Exit early if directory doesn't exist
if [[ ! -d "$DEST_DIR" ]]; then
    log "Invalid directory: $DEST_DIR"
    exit 1
fi

log "--- Post-processing started for: $DEST_DIR ---"

# Parallel unpack .tar.gz, .zip, .rar
find "$DEST_DIR" -type f \( -iname "*.tar.gz" -o -iname "*.zip" -o -iname "*.rar" \) | \
  xargs -r -n1 -P"$(nproc)" -I{} bash -c '
    file="{}"
    if [[ "$file" == *.tar.gz ]]; then
        tar -I pigz -xf "$file" -C "$(dirname "$file")"
    elif [[ "$file" == *.zip ]]; then
        unzip -o "$file" -d "$(dirname "$file")"
    elif [[ "$file" == *.rar ]]; then
        unrar x -o+ "$file" "$(dirname "$file")"
    fi
  '

# Run ffprobe checks on all supported video types
find "$DEST_DIR" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.wmv" \) | \
  while read -r media; do
    scan_and_validate "$media"
  done

log "--- Post-processing completed for: $DEST_DIR ---"
exit 0
