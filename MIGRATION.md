# Migrating to Pi-hole v6

Pi-hole v6 introduces significant changes, notably the removal of `lighttpd` in favor of a built-in web server, and a shift to TOML-based configuration (`pihole.toml`).

## Docker Migration

If you are upgrading an existing Docker deployment:
1. **Environment Variables:** `WEBPASSWORD` and other legacy vars are deprecated. Use `FTLCONF_*` prefixes.
   - Example: `WEBPASSWORD=secret` becomes `FTLCONF_webserver_api_password=secret`.
2. **Volumes:** `/etc/dnsmasq.d` is no longer strictly required for standard configs, as Pi-hole FTL handles everything internally.

See the root `docker-compose.yml` for a modern working example.
