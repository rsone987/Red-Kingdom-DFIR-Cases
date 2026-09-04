#!/bin/bash
# In-Memory vs On-Disk Binary Integrity Check - The Red Kingdom Standard
# Detects process hollowing by comparing a running process's executable memory
# region against the hash of its binary on disk.

PROC_NAME="$1"

if [ -z "$PROC_NAME" ]; then
  echo "Usage: $0 <process_name>"
  exit 1
fi

PID=$(pgrep -x "$PROC_NAME" | head -1)
BIN_PATH=$(readlink -f "/proc/$PID/exe")

echo "[*] Checking $PROC_NAME (PID $PID) against $BIN_PATH..."

DISK_HASH=$(md5sum "$BIN_PATH" | awk '{print $1}')

MAP_LINE=$(grep 'r-xp' "/proc/$PID/maps" | head -1)
START_ADDR=$(echo "$MAP_LINE" | cut -d'-' -f1)
END_ADDR=$(echo "$MAP_LINE" | cut -d'-' -f2 | cut -d' ' -f1)
SIZE=$(( 0x$END_ADDR - 0x$START_ADDR ))

MEM_HASH=$(dd if="/proc/$PID/mem" bs=1 skip=$((0x$START_ADDR)) count="$SIZE" 2>/dev/null | md5sum | awk '{print $1}')

echo "On-disk hash:  $DISK_HASH"
echo "In-memory hash: $MEM_HASH"

if [ "$DISK_HASH" != "$MEM_HASH" ]; then
  echo "[!] MISMATCH — possible process hollowing detected."
else
  echo "[+] Match — process appears to be running its expected on-disk code."
fi
