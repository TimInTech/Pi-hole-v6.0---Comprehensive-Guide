# 🛠️ Pi-hole Resolver v6 — Ultimate Troubleshooting Hub

**Comprehensive Pi-hole v6.x Setup, Fixes & FAQ Guide (Linux/Docker)**

[![Build](https://img.shields.io/github/actions/workflow/status/TimInTech/pi-hole-resolver-v6/ci-sanity.yml?branch=main)](https://github.com/TimInTech/pi-hole-resolver-v6/actions)
[![License](https://img.shields.io/github/license/TimInTech/pi-hole-resolver-v6)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-Donate-ffdd00?logo=buymeacoffee&logoColor=000&labelColor=fff)](https://buymeacoffee.com/timintech)

**Languages:** 🇬🇧 English (this file) • 🇩🇪 [Deutsch](README.de.md)

---

## 🧠 About

> **Current Stack:** Pi-hole Core v6.1.4 / FTL v6.7 / Web v6.6 / Docker 2026.07.x. 

This repository is a centralized hub for resolving common Pi-hole v6.x issues, built to address repetitive problems seen in the community. It includes:
- **Up-to-date for 2026:** Full support for FTL v6.7, Web v6.6, and Docker 2026.07.x migrations.
- **Docker First:** Extensive guide on `FTLCONF_*` environment variables.
- **New Scripts:** Ready-to-run fixes for DB corruption, GUI slowdowns, backups, and v6 upgrades.
- **Companion Repos:** 
  - [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup)
  - [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro)

---

## ⚙️ Quick Start

### 🖥️ Bare-Metal (Linux)

Install Pi-hole directly on your Linux host (Debian/Ubuntu/Raspberry Pi OS):

```bash
curl -sSL https://install.pi-hole.net | bash
```

**Post-Install Check:**
- Access Admin UI: `http://<IP>/admin/` (Pi-hole v6 uses a built-in web server; no lighttpd needed).
- Change password: `sudo pihole -a -p`
- Status check: `sudo systemctl status pihole-FTL`

### 🐳 Docker Compose

For a modern Docker deployment, use our updated `docker-compose.yml` that leverages `FTLCONF_*` variables.

1. Clone the repo or copy `docker-compose.yml` and `.env`.
2. Edit `.env` to set your secure password and timezone.
3. Start the container:

```bash
docker compose up -d
```

> **Note:** Pi-hole v6 deprecates `WEBPASSWORD` in favor of `FTLCONF_webserver_api_password`. Check out the root `docker-compose.yml` for the complete example.

---

## 🔌 Common Errors & Fixes (2026 Edition)

| Problem | Cause (v6.1+ Specific) | Fix |
|---------|-------------------------|-----|
| **Lists not downloading** | Upstream DNS outage or IPv6 misconfig | Run `sudo pihole -g`; check `/etc/resolv.conf`. |
| **FTL DB corruption** | v6 migration bug | Rename DB: `sudo mv /etc/pihole/pihole-FTL.db /etc/pihole/pihole-FTL.db.bak`; `sudo pihole restartdns`. |
| **Web UI inaccessible (403)** | v6.1 built-in server perms | Try `http://<IP>:8080/admin/`; `sudo pihole -r`; check `/etc/pihole/pihole.toml`. |
| **Docker variables ignored** | Deprecated variables used | Switch to `FTLCONF_*` format (e.g. `FTLCONF_webserver_api_password`). |

**Need more help?** Run `pihole -d` for a debug token.

---

## 📚 Documentation & Contribution

- [CHANGELOG.md](CHANGELOG.md) - Version history and updates.
- [MIGRATION.md](MIGRATION.md) - Guide for migrating from v5 to v6.
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute to this repo.

**Maintainer:** TimInTech  
**License:** [MIT](LICENSE)
