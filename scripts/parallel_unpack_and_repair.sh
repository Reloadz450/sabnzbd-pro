#!/bin/bash
set -euo pipefail

START_TIME=$(date +%s)

# Logging function
log() {
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $1"
}

# Inputs and paths
DOWNLOAD_PATH="$1"
CATEGORY_NAME="$(basename "$(dirname "$DOWNLOAD_PATH")")"
DEST_BASE="/data/sab/complete"
FINAL_DEST="${DEST_BASE}/${CATEGORY_NAME}"

# Summary counters
unpack_count=0
par2_count=0
valid_count=0
invalid_count=0

# STEP 1: Validate
log "[STATUS] Step 1/5: Validating job input..."
if [[ -z "$DOWNLOAD_PATH" || ! -d "$DOWNLOAD_PATH" ]]; then
    log "[ERROR] Invalid or missing download path: '$DOWNLOAD_PATH'"
    exit 1
fi
log "[INFO] Category: $CATEGORY_NAME"
log "[INFO] Download path: $DOWNLOAD_PATH"

# STEP 2: Unpack
log "[STATUS] Step 2/5: Searching and unpacking archive files..."
unpack_success=true
while read -r archive; do
    log "[UNPACK] Extracting: $archive"
    7z x -y "$archive" -o"$DOWNLOAD_PATH" >/dev/null 2>&1 && unpack_count=$((unpack_count+1)) || { log "[WARN] Failed to unpack: $archive"; unpack_success=false; }
done < <(find "$DOWNLOAD_PATH" -type f \( -iname '*.rar' -o -iname '*.zip' -o -iname '*.7z' \))

# STEP 3: PAR2 Repair
log "[STATUS] Step 3/5: Checking for PAR2 files and repairing..."
repair_success=true
while read -r par2; do
    par2 r "$par2" >/dev/null 2>&1 && { log "[REPAIR] Success: $par2"; par2_count=$((par2_count+1)); } || { log "[WARN] PAR2 repair failed or not needed: $par2"; repair_success=false; }
done < <(find "$DOWNLOAD_PATH" -type f -name "*.par2")

# STEP 4: Media Validation
log "[STATUS] Step 4/5: Validating video/audio streams via ffprobe..."
valid_video=false
while read -r media; do
    if ffprobe -v error "$media" >/dev/null 2>&1; then
        log "[VALID] OK: $media"
        valid_video=true
        valid_count=$((valid_count+1))
    else
        log "[INVALID] Corrupt: $media"
        invalid_count=$((invalid_count+1))
    fi
done < <(find "$DOWNLOAD_PATH" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.flac" -o -iname "*.mp3" \))

# STEP 5: Move job if clean
log "[STATUS] Step 5/5: Moving to final destination if valid..."
if [[ "$unpack_success" == true && "$repair_success" == true && "$valid_video" == true ]]; then
    mkdir -p "$FINAL_DEST"
    mv "$DOWNLOAD_PATH" "$FINAL_DEST/"
    log "[SUCCESS] Moved to: $FINAL_DEST"
else
    log "[FAILURE] Validation failed. Job left in intermediate."
    exit 1
fi

# Final summary
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log "[SUMMARY] Job Duration: ${DURATION}s"
log "[SUMMARY] Files Unpacked: $unpack_count"
log "[SUMMARY] PAR2 Repaired: $par2_count"
log "[SUMMARY] Valid Media: $valid_count"
log "[SUMMARY] Invalid Media: $invalid_count"
log "[COMPLETE] Post-processing finished."

exit 0
