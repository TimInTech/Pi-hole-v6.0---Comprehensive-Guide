#!/usr/bin/env bash
set -euo pipefail

# Attempts to resolve 403 Forbidden on Pi-hole v6 built-in web UI.

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"
ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

echo "[i] Checking pihole-FTL status"
systemctl status pihole-FTL --no-pager || true

if ss -lnt | grep -E ':(80|8080) ' >/dev/null; then
  ok "Web port detected on 80/8080"
else
  warn "No web port detected on 80/8080"
fi

if [[ ! -f /etc/pihole/pihole.toml ]]; then
  warn "Missing /etc/pihole/pihole.toml — attempting repair"
  sudo pihole -r --reconfigure || true
fi

echo "[i] Restarting services"
if ! sudo pihole restartdns; then
  warn "pihole restartdns failed, trying systemctl"
  sudo systemctl restart pihole-FTL
fi

ok "Try accessing http://<IP>/admin/ or http://<IP>:8080/admin/"
