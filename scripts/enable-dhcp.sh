#!/usr/bin/env bash
set -euo pipefail

# Enables Pi-hole DHCP server with safe defaults.
# Usage: sudo ./scripts/enable-dhcp.sh <RANGE_START> <RANGE_END> <ROUTER_IP>

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"
ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

usage() { echo "Usage: $0 <RANGE_START> <RANGE_END> <ROUTER_IP>"; }

command -v sudo >/dev/null 2>&1 || { err "sudo nicht gefunden"; exit 1; }
command -v pihole >/dev/null 2>&1 || { err "pihole CLI nicht gefunden"; exit 1; }

START=${1:-}
END=${2:-}
ROUTER=${3:-}

if [[ -z "$START" || -z "$END" || -z "$ROUTER" ]]; then
  err "Parameter fehlen"; usage; exit 2
fi

IP_RE='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
for ip in "$START" "$END" "$ROUTER"; do
  if ! [[ $ip =~ $IP_RE ]]; then err "Ungültige IP: $ip"; exit 3; fi
done

echo "[i] Aktiviere DHCP: $START - $END (Router $ROUTER)"
sudo pihole -a enabledhcp "$START" "$END" "$ROUTER"
ok "DHCP enabled: $START - $END via router $ROUTER"
