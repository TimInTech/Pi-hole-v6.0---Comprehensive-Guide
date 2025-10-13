#!/usr/bin/env bash
set -euo pipefail

# Simple backup/restore helper for Pi-hole v6
# Usage:
#   sudo ./scripts/backup-restore.sh backup
#   sudo ./scripts/backup-restore.sh restore /path/to/teleporter.tar.gz

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"
ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

command -v sudo >/dev/null 2>&1 || { err "sudo nicht gefunden. Bitte als root ausführen oder sudo installieren."; exit 1; }
command -v pihole >/dev/null 2>&1 || { err "pihole CLI nicht gefunden."; exit 1; }

CMD=${1:-}
BACKUP_DIR=${BACKUP_DIR:-/var/backups/pihole}
mkdir -p "$BACKUP_DIR"

case "$CMD" in
  backup)
    TS=$(date +%Y%m%d-%H%M%S)
    OUT="$BACKUP_DIR/teleporter-${TS}.tar.gz"
    echo "[i] Creating Teleporter backup -> $OUT"
    sudo pihole -a -t -o "$OUT"
    ok "Backup created: $OUT"
    ;;
  restore)
    FILE=${2:-}
    if [[ -z "$FILE" || ! -f "$FILE" ]]; then
      err "Usage: $0 restore /path/to/teleporter.tar.gz"
      exit 1
    fi
    echo "[i] Restoring from $FILE"
    sudo pihole -a -r -i "$FILE"
    ok "Restore complete"
    ;;
  *)
    err "Usage: $0 {backup|restore <teleporter.tar.gz>}"
    exit 2
    ;;
 esac
