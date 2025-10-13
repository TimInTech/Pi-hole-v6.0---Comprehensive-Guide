#!/usr/bin/env bash
set -euo pipefail

# Checks common post-upgrade issues for v6.1+
# Usage: ./scripts/v6-upgrade-check.sh

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"

ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

command -v systemctl >/dev/null 2>&1 || { warn "systemctl nicht gefunden"; }

# 1. pihole-FTL status
if systemctl is-active --quiet pihole-FTL; then ok "pihole-FTL active"; else err "pihole-FTL inactive"; fi

# 2. pihole.toml exists
if [[ -f /etc/pihole/pihole.toml ]]; then ok "pihole.toml present"; else warn "pihole.toml missing"; fi

# 3. Port 53 conflicts
if ss -lntu | grep -q ':53 '; then ok "Port 53 listening"; else err "Port 53 not listening"; fi

if systemctl is-active --quiet systemd-resolved; then warn "systemd-resolved active (may conflict)"; fi

# 4. Test upstream (Unbound default port 5335)
if command -v dig >/dev/null 2>&1; then
  if dig +short @127.0.0.1 -p 5335 example.com >/dev/null 2>&1; then ok "Unbound responsive on 5335"; else warn "Unbound test failed on 5335"; fi
else
  warn "dig not found"
fi

# 5. DB integrity quick check
if command -v sqlite3 >/dev/null 2>&1 && [[ -f /etc/pihole/pihole-FTL.db ]]; then
  if sqlite3 /etc/pihole/pihole-FTL.db 'PRAGMA integrity_check;' | grep -q '^ok$'; then ok "FTL DB integrity ok"; else warn "FTL DB integrity issues"; fi
else
  warn "sqlite3 or DB missing"
fi

echo "Done. Review warnings above."
