#!/bin/bash
# GRUB Bootloader Hardening - The Red Kingdom Standard

echo "[*] Generating GRUB password hash..."
HASH=$(echo -e "NewStrongPassword\nNewStrongPassword" | grub-mkpasswd-pbkdf2 | grep -o 'grub.pbkdf2.*')

cat >> /etc/grub.d/40_custom << GRUBEOF
set superusers="grubadmin"
password_pbkdf2 grubadmin $HASH
GRUBEOF

echo "[*] Regenerating GRUB config..."
update-grub

echo "[+] GRUB bootloader password set. Boot parameter editing now requires authentication."
