#!/bin/bash
# Firmware Security Audit - The Red Kingdom Standard

echo "[*] Checking Secure Boot state..."
mokutil --sb-state

echo "[*] Checking current boot order..."
efibootmgr -v

echo "[*] Flagging any USB/removable boot entries..."
efibootmgr -v | grep -i "usb\|cd\|removable"
