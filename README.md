# 🛠️ Pi-hole Resolver v6 — Ultimate Troubleshooting Hub (Updated)

**Comprehensive Pi-hole v6.x Setup, Fixes & FAQ Guide (Debian Bookworm/Trixie/Raspberry Pi OS)**

[![Build](https://img.shields.io/github/actions/workflow/status/TimInTech/pi-hole-resolver-v6/ci-sanity.yml?branch=main)](https://github.com/TimInTech/pi-hole-resolver-v6/actions)
[![License](https://img.shields.io/github/license/TimInTech/pi-hole-resolver-v6)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-Donate-ffdd00?logo=buymeacoffee&logoColor=000&labelColor=fff)](https://buymeacoffee.com/timintech)

![Tech](https://skillicons.dev/icons?i=bash,linux,debian,rpi)

**Languages:** 🇬🇧 English (this file) • 🇩🇪 [Deutsch](README.de.md)

---

## 🧠 About

This repository is a **completely new, centralized hub** for resolving common Pi-hole v6.x issues, built from the ground up to address repetitive problems seen in r/pihole and official Discourse threads. It expands on the original [Pi-hole v6.0 Guide](https://github.com/TimInTech/Pi-hole-v6.0---Comprehensive-Guide) by incorporating:

- **Updated for v6.1.4+** (latest core release: July 14, 2025; FTL v6.1: March 30, 2025; Web v6.2: May 30, 2025): Includes built-in web server fixes, FTL database migrations, and post-v6.1 bugfixes for DNS resolution and UI stability.
- **Reddit Sticky FAQs**: Integrated top-voted questions from r/pihole to prevent reposts.
- **2025-Specific Fixes**: DNS failures post-upgrade, 403 Forbidden on admin UI, missing pihole.toml, Docker migration issues, and Unbound conflicts.
- **Verified Links**: All external links checked (Umbrella KB updated; no 404s).
- **New Scripts**: Ready-to-run fixes for DB corruption, GUI slowdowns, backups, and v6 upgrades.
- **Companion Repos**:
  - For automated full-stack setup (Pi-hole + Unbound + NetAlertX): [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) – One-click install with DNSSEC and monitoring.
  - For maintenance: [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro) – Automated updates, backups, and health checks (v5.3.2, Oct 10, 2025).

Search r/pihole first for duplicates—many answers link back here or to [Pi-hole Discourse](https://discourse.pi-hole.net) (official support).

**Repo Structure** (New & Expanded):

- `README.md` / `README.de.md`: This guide.
- `scripts/`: Automated fixers (e.g., `fix-ftl-db.sh`, `optimize-gui.sh`, `v6-upgrade-check.sh`).
- `docs/`: Deep dives (e.g., IPv6 bypass, DoH/DoT blocks, Docker migrations).
- `lists/`: Curated 2025 blocklists (e.g., updated Firebog integrations).
- `LICENSE`: MIT.
- `.github/workflows/`: CI for sanity checks.

---

## ⚙️ Quick Start

### 🔧 Install Pi-hole v6.x

```bash
curl -sSL https://install.pi-hole.net | bash
```

**Post-Install (v6.1+ Specific)**:

- Access Admin UI: `http://<IP>/admin/` (built-in server; no lighttpd needed; check port 80/8080 if 403 error).
- Change password: `pihole -a -p`.
- Verify: `dig pi.hole @<PIHOLE-IP>`.
- **New: Check for v6 DB migration & toml issues**:

  ```bash
  pihole -r  # Repair if FTL fails or no pihole.toml
  sudo systemctl status pihole-FTL  # Ensure no high CPU or DNS failure
  ```

**Companion Setup Tip**: For Unbound integration, use [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) after basic install.

### 🌌 Update & Maintenance (v6.1 Optimized)

```bash
sudo apt update && sudo apt upgrade -y
pihole -up  # Auto-handles v6.1+ upgrades; watch for DNS failures
pihole -g
pihole restartdns
```

**v6 Tip**: Enable auto-backups before updates to avoid DB/toml corruption:

```bash
sudo mkdir -p /var/backups/pihole
sudo tee -a /etc/pihole/pihole-FTL.conf >/dev/null <<'EOF'
BACKUP_DIR=/var/backups/pihole
EOF
sudo systemctl restart pihole-FTL
```

**Automated Option**: Integrate [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro) for cron-based runs.

---

## 🔌 Common Errors & Fixes (2025 Edition)

| Problem | Cause (v6.1+ Specific) | Fix |
|---------|-------------------------|-----|
| **Lists not downloading** | Upstream DNS outage or IPv6 misconfig | Run `pihole -g`; check `/etc/resolv.conf`; test IPv6: `ping6 google.com`. |
| **Only router as client** | Router forwards all DNS | Enable Pi-hole DHCP; disable router DNS rebinding. Script: `scripts/enable-dhcp.sh`. |
| **YouTube ads not blocked** | Ads from video domains | Not feasible via DNS; use uBlock Origin. |
| **Blocked sites fail to load** | Overblocking (e.g., new CDNs) | Query Log whitelist; add 2025 whitelists from `lists/`. |
| **Port 53 conflict** | systemd-resolved or unbound | `sudo systemctl disable --now systemd-resolved`. |
| **FTL DB corruption post-update** | v6.1 migration bug | Rename DB: `sudo mv /etc/pihole/pihole-FTL.db /etc/pihole/pihole-FTL.db.bak`; `pihole restartdns`. Script: `scripts/fix-ftl-db.sh`. |
| **Slow GUI / High CPU (30-70%)** | Built-in server overload on Pi Zero/3 | Limit DB: `MAXDBDAYS=14` in `pihole-FTL.conf`; reduce blocklists. Script: `scripts/optimize-gui.sh`. |
| **Freezes multiple times/day** | Memory leak in FTL v6.0.x | Reinstall + restore config: `pihole uninstall; curl install; Teleporter restore`. |
| **Connection/UDP/NTP errors** | v6 sync issues | `timedatectl set-ntp true`; check upstream DNS (e.g., 1.1.1.1). |
| **No internet after v6 upgrade** | DHCP/DNS loop | Set Pi-hole IP as sole DNS in router; `pihole flush`. |
| **Web UI inaccessible (403 Forbidden)** | v6.1 built-in server perms or port issues | Try `http://<IP>:8080/admin/`; `pihole -r`; check `/etc/pihole/pihole.toml`. Script: `scripts/fix-ui-403.sh`. |
| **DNS Server Failure** | Unbound/upstream conflicts post-v6.1 | Verify upstream in UI; `dig @127.0.0.1 -p 5335 example.com` if using Unbound. See [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup). |
| **Missing pihole.toml after upgrade** | v6.1 config migration fail | `pihole -r --reconfigure`; restore from backup. |
| **Docker v5 to v6 migration issues** | Env vars like WEBPASSWORD or dnsmasq changes | Update compose: Use `-e WEBPASSWORD`; remap volumes; test DHCP statics in new conf. See `docs/docker-v6.md`. |

**Run Debug**: `pihole -d` for token; share on Discourse.

Note on permissions: Most Pi-hole CLI commands require root privileges. Example: `sudo pihole -t` for live tail.

---

## 🔍 Verified FAQ (From r/pihole Sticky + Discourse, Sorted by Views)

| Question | Short Answer | Source |
|----------|--------------|--------|
| How to block YouTube ads? | Not possible with Pi-hole (use browser extensions). | [Discourse #253](https://discourse.pi-hole.net/t/how-do-i-block-ads-on-youtube/253) |
| Unusual DNS queries (e.g., gibberish like "z9d8ejfsdsdf9")? | Chrome prefetching; harmless. | [Umbrella KB (Updated 2025)](https://support.umbrella.com/hc/en-us/articles/115005876643-Unusual-DNS-queries-showing-in-reports) |
| Why ads/content not loading? | Identify domain via Query Log. | [Discourse #1522](https://discourse.pi-hole.net/t/how-do-i-determine-what-domain-an-ad-is-coming-from/1522) |
| How to configure devices for Pi-hole? | Set DNS on devices/router or use Pi-hole DHCP. | [Discourse #245](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245) |
| Router blocks DNS changes? | Use Pi-hole DHCP; disable rebind protection. | [Discourse #3026](https://discourse.pi-hole.net/t/how-do-i-use-pi-holes-built-in-dhcp-server-and-why-would-i-want-to/3026), [#3142](https://discourse.pi-hole.net/t/why-wont-pi-hole-work-with-dns-rebind-protection-enabled/3142) |
| All DNS from router? | Enable Pi-hole DHCP for per-client visibility. | [Discourse #3653](https://discourse.pi-hole.net/t/why-do-i-only-see-my-routers-ip-address-instead-of-individual-devices-in-the-top-clients-section-and-query-log/3653) |
| Secondary DNS recommended? | No—use Pi-hole only to avoid bypasses. | [Discourse #3376](https://discourse.pi-hole.net/t/why-should-pi-hole-be-my-only-dns-server/3376), [#1536](https://discourse.pi-hole.net/t/primary-vs-secondary-dns/1536) |
| Exclude clients from blocking? | Use Group Management (v6 enhanced). | [Discourse #3372](https://discourse.pi-hole.net/t/how-can-i-use-pi-hole-for-all-my-devices-except-one-or-more/3372) |
| Run other software with Pi-hole? | Yes, but monitor resources (e.g., no heavy VMs on Pi Zero). | [Discourse #8684](https://discourse.pi-hole.net/t/can-i-run-other-software-along-side-pi-hole/8684) |
| Add blocklists? | GUI: Group Management → Adlists (2025: Use Firebog for curated). | [Discourse #259](https://discourse.pi-hole.net/t/how-do-i-add-additional-block-lists-to-pi-hole/259); See `lists/2025-firebog.txt` |
| Restore default adlists? | `pihole -g --reset`; or manual via gravity. | [Discourse #32323](https://discourse.pi-hole.net/t/restoring-default-pi-hole-adlists/32323) |
| Remote access (open Port 53?)? | No—use VPN (Tailscale/WireGuard). | [Discourse #13705](https://discourse.pi-hole.net/t/accessing-pi-hole-outside-of-my-lan/13705) |
| **New: DoH/DoT bypass in v6?** | Devices use encrypted DNS. | Block domains like `dns.google`; redirect Port 853 via iptables. See `docs/ipv6-doh.md`. |
| **New: High memory on v6?** | Large FTL DB. | Set `MAXDBDAYS=30`; prune: `pihole vacuum`. |
| **New: DNS failure after v6.1 upgrade?** | Upstream/Unbound misconfig. | Reconfigure upstream; test with `dig`. Use [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) for robust Unbound. |
| **New: Admin panel login/update issues?** | v6.1 perms or NGINX conflicts. | `pihole -r`; disable custom NGINX. |

**Full Sticky List**: See [r/pihole Wiki](https://www.reddit.com/r/pihole/wiki/index) for more.

---

## 📊 Troubleshooting Commands (v6.1 Enhanced)

```bash
# Gravity refresh
pihole -g

# Live log
pihole -t

# Query domain
pihole -q example.com

# Restart (v6: Use restartdns for lighter reload)
pihole restartdns

# v6 DB/toml check/fix
sqlite3 /etc/pihole/pihole-FTL.db "PRAGMA integrity_check;"
ls -la /etc/pihole/pihole.toml  # Verify existence

# Flush cache
pihole flush

# Test upstream (Unbound)
dig @127.0.0.1 -p 5335 example.com
```

**Scripts Usage**:

- `./scripts/fix-high-cpu.sh`: Optimizes for Pi 3/Zero.
- `./scripts/backup-restore.sh`: Teleporter + manual.
- `./scripts/v6-upgrade-check.sh`: Scans for common post-upgrade issues.

**Maintenance Tip**: Run via [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro) for automated health checks.

---

## 🔐 Security & Maintenance (v6.1 Best Practices)

- **Never expose WAN**: Use VPN for remote.
- **Auto-Updates**: `unattended-upgrades` + cron for `pihole -up`.
- **Backups**: Daily via Teleporter; store offsite. Use `--backup` flag in maintenance scripts.
- **v6.1 New**: Enable audit logging: `AUDITLOG=true` in `pihole-FTL.conf`; verify pihole.toml perms.
- **Blocklists 2025**: Start with defaults + `lists/home-2025.txt` (avoids overblocking).
- **Full Stack**: For Unbound + monitoring, deploy [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) – Includes API for stats and DNSSEC.

**Cron Example (Weekly Maintenance)**:

```bash
0 4 * * 0 /usr/local/bin/pihole_maintenance_pro.sh >> /var/log/pihole_maint.log 2>&1
```

(From [pihole-maintenance-pro](https://github.com/TimInTech/pihole-maintenance-pro).)

---

## 🛡️ Support & Contribution

Before posting on r/pihole or Discourse: Search here first! If stuck, run `pihole -d` and share the token.

Support this hub: [☕ Buy me a coffee](https://buymeacoffee.com/timintech) (Valid profile; supports ongoing updates.)

**Fork/Contribute**: PRs for new fixes welcome (e.g., v6.2 previews or Docker issues).

---

**Maintainer:** TimInTech
**Last Updated:** 2025-10-12
**Version:** v6.1.1 (Hub)
**License:** [MIT](LICENSE)

---

## 📚 Additional Docs (New in This Repo)

- **IPv6 Bypass**: `docs/ipv6-doh.md` – Fixes for Android/iOS DoH.
- **Pi Zero W Guide**: `docs/pi-zero-v6.md` – Lightweight config for slow hardware.
- **Docker v6 Migration**: `docs/docker-v6.md` – Env vars, volumes, and static DHCP.
- **Router DNS Setup**: `docs/router-dns.md` – FRITZ!Box, UniFi, Asus, OpenWrt Anleitungen & Links.
- **Unbound Integration**: Links to [Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup) for API/device monitoring.
- **Changelog Sync**: Mirrors [Pi-hole Releases](https://github.com/pi-hole/pi-hole/releases).

For German version: See `README.de.md` (translated FAQs + commands). If you spot issues or need expansions, open an issue!
