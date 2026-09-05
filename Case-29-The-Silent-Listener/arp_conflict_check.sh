#!/bin/bash
# ARP Conflict / Spoofing Check - The Red Kingdom Standard

GATEWAY_IP="$1"
KNOWN_GOOD_MAC="$2"

if [ -z "$GATEWAY_IP" ] || [ -z "$KNOWN_GOOD_MAC" ]; then
  echo "Usage: $0 <gateway_ip> <known_good_mac>"
  exit 1
fi

echo "[*] Checking ARP table for $GATEWAY_IP..."
CURRENT_MAC=$(arp -n "$GATEWAY_IP" | awk '/ether/{print $3}')

echo "Expected MAC: $KNOWN_GOOD_MAC"
echo "Current MAC:  $CURRENT_MAC"

if [ "$CURRENT_MAC" != "$KNOWN_GOOD_MAC" ]; then
  echo "[!] MISMATCH — possible ARP spoofing in progress."
else
  echo "[+] ARP entry matches known-good gateway MAC."
fi

echo "[*] Sniffing for conflicting ARP replies (10s)..."
timeout 10 tcpdump -i eth0 -n arp and src host "$GATEWAY_IP" 2>/dev/null
