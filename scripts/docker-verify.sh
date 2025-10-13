#!/usr/bin/env bash
set -euo pipefail

# docker-verify.sh — Verifiziert Pi-hole/Unbound Deployment
# Checks: offene Ports, Container-Health, Admin-UI, DNS-Query
# Usage: ./scripts/docker-verify.sh [PIHOLE_IP] [ADMIN_PORT]
# Defaults: PIHOLE_IP=192.168.178.21, ADMIN_PORT auto (testet 80, dann 8080)

PIHOLE_IP=${1:-192.168.178.21}
ADMIN_PORT=${2:-}

RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; NC="\e[0m"
ok() { echo -e "${GRN}[OK]${NC} $*"; }
warn() { echo -e "${YLW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*"; }

# 1) Docker status
if ! command -v docker >/dev/null 2>&1; then err "docker nicht gefunden"; exit 1; fi
ok "docker vorhanden"

# 2) Container laufen?
PH=$(docker ps --format '{{.Names}}' | grep -E '^pihole$' || true)
UB=$(docker ps --format '{{.Names}}' | grep -E '^unbound$' || true)
[[ -n "$PH" ]] && ok "Container pihole läuft" || warn "Container pihole läuft nicht"
[[ -n "$UB" ]] && ok "Container unbound läuft" || warn "Container unbound läuft nicht (optional)"

# 3) Healthchecks
if [[ -n "$PH" ]]; then
  HS=$(docker inspect --format='{{json .State.Health.Status}}' pihole 2>/dev/null || echo '"unknown"')
  echo "pihole health: $HS"
fi
if [[ -n "$UB" ]]; then
  HS=$(docker inspect --format='{{json .State.Health.Status}}' unbound 2>/dev/null || echo '"unknown"')
  echo "unbound health: $HS"
fi

# 4) Ports offen (Host)
if command -v ss >/dev/null 2>&1; then
  ss -lntup | grep -E ':(53|80|8080) ' || warn "Ports 53/80/8080 nicht sichtbar (je nach Modus ok)"
else
  warn "ss nicht verfügbar, Portprüfung übersprungen"
fi

# 5) Admin UI erreichbar?
if command -v curl >/dev/null 2>&1; then
  if [[ -z "$ADMIN_PORT" ]]; then
    for PORT in 80 8080; do
      if curl -fsS "http://${PIHOLE_IP}:${PORT}/admin/" >/dev/null; then
        ok "Admin UI erreichbar: http://${PIHOLE_IP}:${PORT}/admin/"
        ADMIN_PORT=$PORT
        break
      fi
    done
    if [[ -z "${ADMIN_PORT}" ]]; then
      warn "Admin UI weder auf Port 80 noch 8080 erreichbar"
    fi
  else
    if curl -fsS "http://${PIHOLE_IP}:${ADMIN_PORT}/admin/" >/dev/null; then
      ok "Admin UI erreichbar: http://${PIHOLE_IP}:${ADMIN_PORT}/admin/"
    else
      warn "Admin UI nicht erreichbar unter http://${PIHOLE_IP}:${ADMIN_PORT}/admin/"
    fi
  fi
else
  warn "curl nicht verfügbar"
fi

# 6) DNS Test (A-Record)
if command -v dig >/dev/null 2>&1; then
  if dig +time=2 +tries=1 @"${PIHOLE_IP}" pi.hole A +short >/dev/null; then
    ok "DNS-Query erfolgreich gegen ${PIHOLE_IP}"
  else
    err "DNS-Query fehlgeschlagen gegen ${PIHOLE_IP}"
  fi
else
  warn "dig nicht verfügbar"
fi

# 7) Unbound Port test (falls vorhanden)
if [[ -n "$UB" ]] && command -v dig >/dev/null 2>&1; then
  if dig +time=2 +tries=1 @127.0.0.1 -p 5335 example.com +short >/dev/null; then
    ok "Unbound erreichbar auf 5335"
  else
    warn "Unbound Test fehlgeschlagen (Port 5335)"
  fi
fi

echo "Fertig. Prüfe WARN/ERR oben."
