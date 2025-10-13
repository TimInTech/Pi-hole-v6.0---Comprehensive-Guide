#!/usr/bin/env bash
set -euo pipefail

# Optimize Pi-hole v6 for low-power devices.
# Usage: sudo ./scripts/optimize-gui.sh

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"
ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

command -v sudo >/dev/null 2>&1 || { err "sudo nicht gefunden. Bitte als root ausführen oder sudo installieren."; exit 1; }

CONF="/etc/pihole/pihole-FTL.conf"
backup_conf() {
  sudo cp -a "$CONF" "${CONF}.bak-$(date +%Y%m%d-%H%M%S)" || true
}

backup_conf

# Ensure MAXDBDAYS is set to 14
if grep -q '^MAXDBDAYS=' "$CONF"; then
  sudo sed -i 's/^MAXDBDAYS=.*/MAXDBDAYS=14/' "$CONF"
else
  echo 'MAXDBDAYS=14' | sudo tee -a "$CONF" >/dev/null
fi

echo "[i] Set MAXDBDAYS=14 in $CONF"

echo "[i] Restarting FTL"
if ! sudo pihole restartdns; then
  warn "pihole restartdns failed, trying systemctl"
  sudo systemctl restart pihole-FTL
fi

ok "Optimization applied. Consider reducing adlists if CPU remains high."
