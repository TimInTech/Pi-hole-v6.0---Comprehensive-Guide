# 🛠️ Pi-hole Resolver v6 — Ultimativer Troubleshooting-Hub (Aktualisiert)

Umfassender Pi-hole v6.x Setup-, Fix- und FAQ-Leitfaden (Debian Bookworm/Trixie/Raspberry Pi OS)

[![Build](https://img.shields.io/github/actions/workflow/status/TimInTech/pi-hole-resolver-v6/ci-sanity.yml?branch=main)](https://github.com/TimInTech/pi-hole-resolver-v6/actions)
[![License](https://img.shields.io/github/license/TimInTech/pi-hole-resolver-v6)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-Spenden-ffdd00?logo=buymeacoffee&logoColor=000&labelColor=fff)](https://buymeacoffee.com/timintech)

![Technik](https://skillicons.dev/icons?i=bash,linux,debian,rpi)

**Sprachen:** 🇩🇪 Deutsch (diese Datei) • 🇬🇧 [English](README.md)

---

## 🧠 Über dieses Projekt

Dieses Repository ist ein **zentraler Hub** zur Lösung häufiger Pi-hole v6.x-Probleme. Es baut auf dem ursprünglichen [Pi-hole v6.0 Guide](https://github.com/TimInTech/Pi-hole-v6.0---Comprehensive-Guide) auf und adressiert wiederkehrende Themen aus r/pihole und dem offiziellen Discourse:

- **Aktualisiert für v6.1.4+** (neueste Core-Release: 14. Juli 2025; FTL v6.1: 30. März 2025; Web v6.2: 30. Mai 2025): Beinhaltet Fixes für den eingebauten Webserver, FTL-Datenbankmigrationen sowie Bugfixes rund um DNS-Auflösung und UI-Stabilität.
- **Reddit-Sticky-FAQs**: Häufigste Fragen integriert, um Doppelposts zu vermeiden.
- **Spezifische 2025-Fixes**: DNS-Ausfälle nach Upgrade, 403 Forbidden im Admin-UI, fehlende pihole.toml, Docker-Migration, Unbound-Konflikte.
- **Verifizierte Links**: Externe Links geprüft (Umbrella KB aktualisiert; keine 404s).
- **Neue Skripte**: Ausführbare Helfer für DB-Reparatur, GUI-Optimierung, Backups und v6-Upgrades.
- **Companion-Repos**:
  - Automatisiertes Full-Stack-Setup (Pi-hole + Unbound + NetAlertX): [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) – One-Click-Install mit DNSSEC und Monitoring.
  - Wartung: [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro) – Automatische Updates, Backups und Health Checks (v5.3.2, 10. Okt. 2025).

Bitte zuerst r/pihole durchsuchen—viele Antworten verweisen hierher oder auf das [Pi-hole Discourse](https://discourse.pi-hole.net) (offizieller Support).

**Repo-Struktur** (Neu & erweitert):

- `README.md` / `README.de.md`: Dieser Leitfaden.
- `scripts/`: Automatisierte Fixer (z. B. `fix-ftl-db.sh`, `optimize-gui.sh`, `v6-upgrade-check.sh`).
- `docs/`: Hintergrundwissen (z. B. IPv6-Umgehung, DoH/DoT-Blocks, Docker-Migrationen).
- `lists/`: Kuratierte Blocklisten 2025 (inkl. aktualisierte Firebog-Integrationen).
- `LICENSE`: MIT.
- `.github/workflows/`: CI-Sanity-Checks.

---

## ⚙️ Schnellstart

### 🔧 Pi-hole v6.x installieren

```bash
curl -sSL https://install.pi-hole.net | bash
```

**Nach der Installation (v6.1+ spezifisch):**

- Admin-UI: `http://<IP>/admin/` (eingebauter Webserver; kein lighttpd nötig; prüfe Port 80/8080 bei 403-Fehlern).
- Passwort ändern: `pihole -a -p`.
- Test: `dig pi.hole @<PIHOLE-IP>`.
- **Neu: v6 DB-Migration & toml prüfen**:

```bash
pihole -r  # Reparatur, falls FTL fehlschlägt oder pihole.toml fehlt
sudo systemctl status pihole-FTL  # Sicherstellen, dass CPU/DNS ok sind
```

**Tipp für Unbound**: Für Unbound-Integration nach der Basisinstallation [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) verwenden.

### 🌌 Update & Wartung (für v6.1 optimiert)

```bash
sudo apt update && sudo apt upgrade -y
pihole -up  # Handhabt v6.1+ Upgrades; auf DNS-Ausfälle achten
pihole -g
pihole restartdns
```

**v6-Tipp**: Vor Updates Auto-Backups aktivieren, um DB/toml-Korruption zu vermeiden:

```bash
sudo mkdir -p /var/backups/pihole
sudo tee -a /etc/pihole/pihole-FTL.conf >/dev/null <<'EOF'
BACKUP_DIR=/var/backups/pihole
EOF
sudo systemctl restart pihole-FTL
```

**Automatisierte Option**: [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro) für cron-basierte Läufe integrieren.

---

## 🔌 Häufige Fehler & Lösungen (Ausgabe 2025)

| Problem | Ursache (v6.1+ spezifisch) | Lösung |
|---------|-----------------------------|--------|
| **Listen laden nicht** | Upstream-DNS-Ausfall oder IPv6-Fehlkonfig | `pihole -g`; `/etc/resolv.conf` prüfen; IPv6 testen: `ping6 google.com`. |
| **Nur Router als Client sichtbar** | Router leitet sämtlichen DNS weiter | Pi-hole DHCP aktivieren; Router „DNS-Rebinding“ deaktivieren. Skript: `scripts/enable-dhcp.sh`. |
| **YouTube-Werbung nicht blockbar** | Ads von Videodomains | Per DNS nicht zuverlässig möglich; uBlock Origin verwenden. |
| **Seiten laden nicht (Overblocking)** | Z. B. neue CDNs | Im Query Log whitelisten; 2025-Whitelist aus `lists/` nutzen. |
| **Port 53 Konflikt** | systemd-resolved oder Unbound | `sudo systemctl disable --now systemd-resolved`. |
| **FTL-DB korrupt nach Update** | v6.1 Migrationsfehler | DB umbenennen: `sudo mv /etc/pihole/pihole-FTL.db /etc/pihole/pihole-FTL.db.bak`; `pihole restartdns`. Skript: `scripts/fix-ftl-db.sh`. |
| **Langsame GUI / hohe CPU (30–70%)** | Eingebauter Server überlastet (Pi Zero/3) | `MAXDBDAYS=14` in `pihole-FTL.conf`; Blocklisten reduzieren. Skript: `scripts/optimize-gui.sh`. |
| **Mehrfach täglich Freezes** | Memory-Leak in FTL v6.0.x | Neuinstallation + Restore: `pihole uninstall; curl install; Teleporter restore`. |
| **Verbindungs-/UDP-/NTP-Fehler** | v6 Sync-Probleme | `timedatectl set-ntp true`; Upstream-DNS prüfen (z. B. 1.1.1.1). |
| **Kein Internet nach v6-Upgrade** | DHCP/DNS-Schleife | Pi-hole-IP als einzigen DNS im Router setzen; `pihole flush`. |
| **Web-UI (403 Forbidden)** | v6.1 eingebauter Webserver: Rechte/Port | `http://<IP>:8080/admin/` probieren; `pihole -r`; `/etc/pihole/pihole.toml` prüfen. Skript: `scripts/fix-ui-403.sh`. |
| **DNS Server Failure** | Unbound/Upstream-Konflikte nach v6.1 | Upstream in UI prüfen; `dig @127.0.0.1 -p 5335 example.com`. Siehe [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup). |
| **pihole.toml fehlt nach Upgrade** | v6.1 Konfig-Migration fehlgeschlagen | `pihole -r --reconfigure`; aus Backup wiederherstellen. |
| **Docker v5→v6 Migration** | Env-Variablen (WEBPASSWORD) oder dnsmasq-Änderungen | Compose aktualisieren: `-e WEBPASSWORD`; Volumes neu abbilden; DHCP-Statics prüfen. Siehe `docs/docker-v6.md`. |

**Debug ausführen**: `pihole -d` (Token teilen im Discourse).

Hinweis zu Rechten: Viele Pi-hole CLI-Befehle benötigen Root-Rechte. Beispiel: `sudo pihole -t` für Live-Log.

---

## 🔍 Verifizierte FAQ (aus r/pihole Sticky & Discourse, nach Views sortiert)

| Frage | Kurzantwort | Quelle |
|-------|-------------|--------|
| Wie blocke ich YouTube-Werbung? | Mit Pi-hole nicht zuverlässig (Browser-Erweiterungen nutzen). | [Discourse #253](https://discourse.pi-hole.net/t/how-do-i-block-ads-on-youtube/253) |
| Ungewöhnliche DNS-Anfragen (z. B. „z9d8ejfsdsdf9“)? | Chrome-Prefetch; harmlos. | [Umbrella KB (2025)](https://support.umbrella.com/hc/en-us/articles/115005876643-Unusual-DNS-queries-showing-in-reports) |
| Warum laden Inhalte nicht? | Domain im Query Log identifizieren. | [Discourse #1522](https://discourse.pi-hole.net/t/how-do-i-determine-what-domain-an-ad-is-coming-from/1522) |
| Wie nutze ich Pi-hole auf Geräten/Router? | DNS am Gerät/Router setzen oder Pi-hole DHCP nutzen. | [Discourse #245](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245) |
| Router blockiert DNS-Änderungen? | Pi-hole DHCP nutzen; Rebind-Schutz deaktivieren. | [#3026](https://discourse.pi-hole.net/t/how-do-i-use-pi-holes-built-in-dhcp-server-and-why-would-i-want-to/3026), [#3142](https://discourse.pi-hole.net/t/why-wont-pi-hole-work-with-dns-rebind-protection-enabled/3142) |
| Alle DNS-Anfragen vom Router? | Pi-hole DHCP aktivieren für per-Client-Sicht. | [#3653](https://discourse.pi-hole.net/t/why-do-i-only-see-my-routers-ip-address-instead-of-individual-devices-in-the-top-clients-section-and-query-log/3653) |
| Zweiter DNS empfohlen? | Nein – nur Pi-hole, um Umgehungen zu verhindern. | [#3376](https://discourse.pi-hole.net/t/why-should-pi-hole-be-my-only-dns-server/3376), [#1536](https://discourse.pi-hole.net/t/primary-vs-secondary-dns/1536) |
| Geräte vom Blocken ausnehmen? | Gruppenverwaltung nutzen (v6 verbessert). | [#3372](https://discourse.pi-hole.net/t/how-can-i-use-pi-hole-for-all-my-devices-except-one-or-more/3372) |
| Andere Software mit Pi-hole betreiben? | Ja, aber Ressourcen im Blick behalten. | [#8684](https://discourse.pi-hole.net/t/can-i-run-other-software-along-side-pi-hole/8684) |
| Blocklisten hinzufügen? | GUI: Gruppenverwaltung → Adlists (2025: Firebog nutzen). | [#259](https://discourse.pi-hole.net/t/how-do-i-add-additional-block-lists-to-pi-hole/259); siehe `lists/2025-firebog.txt` |
| Standard-Adlists wiederherstellen? | `pihole -g --reset`; oder manuell via Gravity. | [#32323](https://discourse.pi-hole.net/t/restoring-default-pi-hole-adlists/32323) |
| Remote-Zugriff (Port 53 öffnen)? | Nein – VPN nutzen (Tailscale/WireGuard). | [#13705](https://discourse.pi-hole.net/t/accessing-pi-hole-outside-of-my-lan/13705) |
| **Neu: DoH/DoT-Umgehung in v6?** | Geräte nutzen verschlüsseltes DNS. | Domains wie `dns.google` blocken; Port 853 via iptables/nftables sperren. Siehe `docs/ipv6-doh.md`. |
| **Neu: Hoher Speicherverbrauch in v6?** | Große FTL-DB. | `MAXDBDAYS=30` setzen; `pihole vacuum`. |
| **Neu: DNS-Fehler nach v6.1-Upgrade?** | Upstream/Unbound-Fehlkonfig. | Upstream neu setzen; mit `dig` testen. Siehe [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup). |
| **Neu: Admin-Panel Login/Update-Probleme?** | v6.1 Berechtigungen oder NGINX-Konflikte. | `pihole -r`; eigenes NGINX deaktivieren. |

Vollständige Sticky-Liste: Siehe [r/pihole Wiki](https://www.reddit.com/r/pihole/wiki/index).

---

## 📊 Diagnose-Befehle (v6.1 erweitert)

```bash
# Gravity-Refresh
pihole -g

# Live-Log
pihole -t

# Domain abfragen
pihole -q example.com

# Neustart (v6: leichterer Reload)
pihole restartdns

# v6 DB/toml prüfen/reparieren
sqlite3 /etc/pihole/pihole-FTL.db "PRAGMA integrity_check;"
ls -la /etc/pihole/pihole.toml  # Existenz prüfen

# Cache leeren
pihole flush

# Upstream (Unbound) testen
dig @127.0.0.1 -p 5335 example.com
```

**Skript-Nutzung**:

- `./scripts/fix-high-cpu.sh`: Optimierungen für Pi 3/Zero.
- `./scripts/backup-restore.sh`: Teleporter + manuell.
- `./scripts/v6-upgrade-check.sh`: Scans für häufige Post-Upgrade-Probleme.

**Wartungstipp**: Per [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro) automatisierte Health-Checks durchführen.

---

## 🔐 Sicherheit & Wartung (v6.1 Best Practices)

- **Kein WAN-Expose**: Für Remote-Zugriff VPN nutzen.
- **Auto-Updates**: `unattended-upgrades` + cron für `pihole -up`.
- **Backups**: Täglich via Teleporter; Offsite speichern. `--backup`-Flags in Skripten nutzen.
- **Neu in v6.1**: Audit-Log aktivieren: `AUDITLOG=true` in `pihole-FTL.conf`; pihole.toml-Rechte prüfen.
- **Blocklisten 2025**: Mit Defaults starten + `lists/home-2025.txt` (vermeidet Overblocking).
- **Full Stack**: Für Unbound + Monitoring: [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) – inkl. API für Stats und DNSSEC.

**Cron-Beispiel (wöchentlich)**:

```bash
0 4 * * 0 /usr/local/bin/pihole_maintenance_pro.sh >> /var/log/pihole_maint.log 2>&1
```

---

## 🛡️ Support & Beitrag

Vor Posts in r/pihole oder Discourse: Erst hier suchen! Bei Problemen `pihole -d` ausführen und den Token teilen.

Unterstütze das Projekt: [☕ Buy me a coffee](https://buymeacoffee.com/timintech) (valider Account; hilft bei laufenden Updates).

**Fork/Contribute**: PRs für neue Fixes willkommen (z. B. v6.2 Previews oder Docker-Themen).

---

**Maintainer:** TimInTech
**Zuletzt aktualisiert:** 2025-10-12
**Version:** v6.1.1 (Hub)
**Lizenz:** [MIT](LICENSE)

---

## 📚 Weitere Dokumente (neu in diesem Repo)

- **IPv6-Umgehungen/DoH**: `docs/ipv6-doh.md` – Fixes für Android/iOS DoH.
- **Pi Zero W Leitfaden**: `docs/pi-zero-v6.md` – Leichtgewicht-Setup für schwache Hardware.
- **Docker v6 Migration**: `docs/docker-v6.md` – Env-Variablen, Volumes und statisches DHCP.
- **Router-DNS-Einrichtung**: `docs/router-dns.md` – FRITZ!Box, UniFi, Asus, OpenWrt Anleitungen & Links.
- **Unbound-Integration**: Verweise auf [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) für API/Monitoring.
- **Changelog-Sync**: Spiegel der [Pi-hole Releases](https://github.com/pi-hole/pi-hole/releases).

Falls du Fehler entdeckst oder Erweiterungen wünschst, öffne gern ein Issue!
