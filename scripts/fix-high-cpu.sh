#!/usr/bin/env bash
set -euo pipefail

# Wrapper to apply common performance tweaks
# Usage: sudo ./scripts/fix-high-cpu.sh

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"
ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! bash "${SCRIPT_DIR}/optimize-gui.sh"; then
	err "optimize-gui.sh fehlgeschlagen"
fi

if command -v pihole >/dev/null 2>&1; then
	if sudo pihole -g; then ok "Gravity aktualisiert"; else warn "pihole -g fehlgeschlagen"; fi
else
	warn "pihole nicht gefunden"
fi

echo "[i] Tipp: Blocklisten reduzieren und ressourcenintensive Dienste prüfen."
