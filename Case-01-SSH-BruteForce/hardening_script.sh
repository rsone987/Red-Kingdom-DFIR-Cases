#!/bin/bash
# Hardening Script for SSH Server - The Red Kingdom Standard

echo "[*] Hardening SSH Configuration..."
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

echo "[*] Reloading SSH Daemon..."
sudo systemctl reload sshd

echo "[+] SSH Protocol successfully hardened."
