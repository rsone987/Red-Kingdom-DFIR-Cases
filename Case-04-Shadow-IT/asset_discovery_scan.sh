#!/bin/bash
# Continuous Asset Discovery - The Red Kingdom Standard
# Sweeps the routable range and flags anything not in the known-asset inventory

KNOWN_ASSETS="known_assets.csv"
NETWORK_RANGE="203.0.113.0/24"

echo "[*] Sweeping $NETWORK_RANGE..."
nmap -sn "$NETWORK_RANGE" -oG - | awk '/Up$/{print $2}' > live_hosts.txt

echo "[*] Comparing against known inventory..."
comm -23 <(sort live_hosts.txt) <(cut -d',' -f1 "$KNOWN_ASSETS" | sort) > unregistered_hosts.txt

if [ -s unregistered_hosts.txt ]; then
  echo "[!] Unregistered hosts found:"
  cat unregistered_hosts.txt
else
  echo "[+] No unregistered hosts detected."
fi
