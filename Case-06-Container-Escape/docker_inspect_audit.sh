#!/bin/bash
# Fleet-wide Privileged Container & Socket Mount Audit - The Red Kingdom Standard

echo "[*] Scanning running containers for dangerous configurations..."
for cid in $(docker ps -q); do
  name=$(docker inspect --format '{{ .Name }}' "$cid")
  privileged=$(docker inspect --format '{{ .HostConfig.Privileged }}' "$cid")
  binds=$(docker inspect --format '{{ .HostConfig.Binds }}' "$cid")
  user=$(docker inspect --format '{{ .Config.User }}' "$cid")

  if [[ "$privileged" == "true" ]] || [[ "$binds" == *"docker.sock"* ]] || [[ -z "$user" ]]; then
    echo "[!] $name — privileged=$privileged, user='${user:-root}', binds=$binds"
  fi
done
echo "[+] Audit complete."
