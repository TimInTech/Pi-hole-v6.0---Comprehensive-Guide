#!/usr/bin/env bash
set -euo pipefail

# Fix potential FTL DB corruption by rotating the DB and restarting DNS.
# Usage: sudo ./scripts/fix-ftl-db.sh

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"
ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

command -v sudo >/dev/null 2>&1 || { err "sudo nicht gefunden. Bitte als root ausführen oder sudo installieren."; exit 1; }

DB="/etc/pihole/pihole-FTL.db"
TS=$(date +%Y%m%d-%H%M%S)

if [[ -f "$DB" ]]; then
  echo "[i] Backing up $DB to ${DB}.bak-${TS}"
  sudo cp -a "$DB" "${DB}.bak-${TS}"
  echo "[i] Moving current DB to ${DB}.migrated-${TS}"
  sudo mv "$DB" "${DB}.migrated-${TS}"
else
  warn "$DB not found, continue with restartdns"
fi

echo "[i] Restarting pihole-FTL"
if ! sudo pihole restartdns; then
  warn "pihole restartdns failed, trying systemctl restart pihole-FTL"
  sudo systemctl restart pihole-FTL
fi

ok "Done. Check web UI and logs."
