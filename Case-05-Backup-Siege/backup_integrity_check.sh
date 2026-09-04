#!/bin/bash
# Backup Integrity & Restore Test - The Red Kingdom Standard

REPO="/mnt/backup-repo"

echo "[*] Verifying backup repository integrity..."
restic -r "$REPO" check --read-data

echo "[*] Performing sample restore test..."
LATEST_SNAPSHOT=$(restic -r "$REPO" snapshots --latest 1 --json | jq -r '.[0].id')
restic -r "$REPO" restore "$LATEST_SNAPSHOT" --target /tmp/restore-test

if [ $? -eq 0 ]; then
  echo "[+] Restore test passed for snapshot $LATEST_SNAPSHOT"
else
  echo "[!] Restore test FAILED — investigate immediately"
fi
