#!/bin/bash
# Pre-Commit Secret Scanning Hook - The Red Kingdom Standard
# Blocks commits that appear to contain hardcoded credentials

PATTERN='(AKIA[0-9A-Z]{16}|aws_secret_access_key|-----BEGIN (RSA|OPENSSH) PRIVATE KEY-----|password\s*[:=]\s*["'\''][^"'\'']{6,}["'\''])'

MATCHES=$(git diff --cached -U0 | grep -E "$PATTERN")

if [ -n "$MATCHES" ]; then
  echo "[!] Commit blocked — possible secret detected:"
  echo "$MATCHES"
  echo "[!] Remove the secret and use the secrets manager instead."
  exit 1
fi

echo "[+] No obvious secrets detected. Proceeding with commit."
exit 0
