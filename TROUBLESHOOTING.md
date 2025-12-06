# 🛠️ Pi-hole v6 Troubleshooting Guide (2025)

Stack: Pi-hole Core 6.1.4 / FTL 6.1 / Web 6.2 on Raspberry Pi 3/4 (Debian Bookworm/Trixie). Built-in web server only—no lighttpd.

---

## 1) Port 53 Conflicts (systemd-resolved/dnsmasq)

- Check listeners: `ss -tulpn | grep ':53' || netstat -tulpn | grep ':53'`.
- Disable conflicting resolvers: `sudo systemctl disable --now systemd-resolved`; stop other DNS daemons or Docker containers binding 53.
- Reapply Pi-hole DNS bindings: `sudo pihole restartdns`.
- Validate with `scripts/v6-upgrade-check.sh` (includes port 53 checks) and ensure clients use only the Pi-hole IP.

## 2) FTL DB Corruption / Web UI 403 (built-in server)

- Repair DB safely: `sudo bash scripts/fix-ftl-db.sh` (backs up `pihole-FTL.db`, recreates indexes).
- Fix 403 or missing `pihole.toml`: `sudo bash scripts/fix-ui-403.sh` to refresh built-in web server permissions.
- Restart services: `sudo pihole restartdns` and `sudo systemctl status pihole-FTL`.
- Still broken? Run `sudo pihole -r --reconfigure` to rebuild the v6 config, then rerun the fix scripts if needed.

## 3) DNS Outages / Upstream Failures

- Unbound path: `dig @127.0.0.1 -p 5335 example.com`; if it fails, restart Unbound or update root hints.
- Pi-hole path: `sudo pihole -g && sudo pihole restartdns`; confirm `pihole-FTL` is `active (running)`.
- Run `sudo bash scripts/v6-upgrade-check.sh` to catch known v6.1 upgrade issues (pihole.toml missing, bad upstreams).
- Docker users: verify host networking with `scripts/docker-verify.sh` if running Pi-hole in a container.

## 4) DHCP & Client Visibility

- Enable Pi-hole DHCP for per-client logs: `sudo bash scripts/enable-dhcp.sh`.
- Disable router DNS helpers/rebind protection that overwrite client DNS.
- Block DNS bypass: firewall outbound port 53/853 to anything except Pi-hole and your upstream/Unbound box.
- After enabling DHCP, renew leases on clients or reboot access points.

## Quick References

- Logs: `sudo journalctl -u pihole-FTL -f`
- Health: `sudo pihole status` and `dig pi.hole @<PIHOLE-IP>`
- Backups: use `scripts/backup-restore.sh` before major upgrades.
