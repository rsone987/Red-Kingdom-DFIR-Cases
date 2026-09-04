#!/bin/bash
# Kernel Module Integrity Check - The Red Kingdom Standard

BASELINE="known_clean_modules.txt"

echo "[*] Comparing loaded modules against known-clean baseline..."
lsmod | awk 'NR>1 {print $1}' | sort > /tmp/current_modules.txt
sort "$BASELINE" > /tmp/baseline_modules.txt

diff /tmp/baseline_modules.txt /tmp/current_modules.txt > /tmp/module_diff.txt

if [ -s /tmp/module_diff.txt ]; then
  echo "[!] Unexpected module differences found:"
  cat /tmp/module_diff.txt
else
  echo "[+] No unexpected modules loaded."
fi

echo "[*] Cross-checking /proc entries against ps output..."
proc_count=$(ls /proc | grep -E '^[0-9]+$' | wc -l)
ps_count=$(ps -e --no-headers | wc -l)
echo "/proc process entries: $proc_count | ps-reported processes: $ps_count"
if [ "$proc_count" -ne "$ps_count" ]; then
  echo "[!] Mismatch detected — possible hidden process(es)."
fi
