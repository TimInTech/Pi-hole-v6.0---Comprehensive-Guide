# 🛠️ Pi-hole Resolver v6 — Ultimativer Troubleshooting-Hub

**Umfassender Pi-hole v6.x Setup-, Fix- und FAQ-Leitfaden (Linux/Docker)**

[![Build](https://img.shields.io/github/actions/workflow/status/TimInTech/pi-hole-resolver-v6/ci-sanity.yml?branch=main)](https://github.com/TimInTech/pi-hole-resolver-v6/actions)
[![License](https://img.shields.io/github/license/TimInTech/pi-hole-resolver-v6)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-Spenden-ffdd00?logo=buymeacoffee&logoColor=000&labelColor=fff)](https://buymeacoffee.com/timintech)

**Sprachen:** 🇩🇪 Deutsch (diese Datei) • 🇬🇧 [English](README.md)

---

## 🧠 Über dieses Projekt

> **Aktueller Stack:** Pi-hole Core v6.1.4 / FTL v6.7 / Web v6.6 / Docker 2026.07.x.

Dieses Repository ist ein zentraler Hub zur Lösung häufiger Pi-hole v6.x-Probleme. Es beinhaltet:
- **Aktualisiert für 2026:** Volle Unterstützung für FTL v6.7, Web v6.6 und Docker 2026.07.x.
- **Docker-Fokus:** Ausführlicher Leitfaden zu den neuen `FTLCONF_*` Umgebungsvariablen.
- **Neue Skripte:** Helfer für DB-Reparatur, GUI-Optimierung, Backups und v6-Upgrades.
- **Companion-Repos:** 
  - [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup)
  - [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro)

---

## ⚙️ Schnellstart

### 🖥️ Bare-Metal (Linux)

Pi-hole direkt auf einem Linux-Host installieren (Debian/Ubuntu/Raspberry Pi OS):

```bash
curl -sSL https://install.pi-hole.net | bash
```

**Prüfung nach der Installation:**
- Admin-UI: `http://<IP>/admin/` (Pi-hole v6 nutzt einen eingebauten Webserver; kein lighttpd nötig).
- Passwort ändern: `sudo pihole -a -p`
- Status-Check: `sudo systemctl status pihole-FTL`

### 🐳 Docker Compose

Für ein modernes Docker-Deployment nutze unsere `docker-compose.yml`, die auf `FTLCONF_*` Variablen setzt.

1. Repo klonen oder `docker-compose.yml` und `.env` kopieren.
2. `.env` anpassen (Passwort und Zeitzone).
3. Container starten:

```bash
docker compose up -d
```

> **Hinweis:** In Pi-hole v6 ist `WEBPASSWORD` veraltet; stattdessen wird `FTLCONF_webserver_api_password` genutzt. Ein vollständiges Beispiel findest du in der Root-`docker-compose.yml`.

---

## 🔌 Häufige Fehler & Lösungen (Ausgabe 2026)

| Problem | Ursache (v6.1+ spezifisch) | Lösung |
|---------|-----------------------------|--------|
| **Listen laden nicht** | Upstream-DNS-Ausfall / IPv6 | `sudo pihole -g`; `/etc/resolv.conf` prüfen. |
| **FTL-DB korrupt** | v6 Migrationsfehler | DB umbenennen: `sudo mv /etc/pihole/pihole-FTL.db /etc/pihole/pihole-FTL.db.bak`; `sudo pihole restartdns`. |
| **Web-UI (403)** | v6.1 Webserver Rechte | `http://<IP>:8080/admin/` probieren; `sudo pihole -r`; `/etc/pihole/pihole.toml` prüfen. |
| **Docker-Variablen ignoriert**| Veraltete Variablen | Auf `FTLCONF_*` Format wechseln (z. B. `FTLCONF_webserver_api_password`). |

**Mehr Hilfe?** `pihole -d` ausführen für ein Debug-Token.

---

## 📚 Dokumentation & Beitrag

- [CHANGELOG.md](CHANGELOG.md) - Versionshistorie.
- [MIGRATION.md](MIGRATION.md) - Migrationsleitfaden von v5 auf v6.
- [CONTRIBUTING.md](CONTRIBUTING.md) - Wie man hier mitwirken kann.

**Maintainer:** TimInTech  
**Lizenz:** [MIT](LICENSE)
