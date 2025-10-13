# Docker v6 Migration Guide + Compose Beispiele (2025)

Dieser Leitfaden hilft beim Umstieg von Pi-hole v5 (Container) auf v6.x, inklusive konkreter Docker Compose Beispiele.

## Wichtige Änderungen von v5 -> v6

- Integrierter Webserver: v6 nutzt einen eingebauten Webserver (kein lighttpd im Container). Standard-Port ist 80 (Fallback häufig 8080).
- `WEBPASSWORD`: Das Admin-Passwort wird als Umgebungsvariable gesetzt: `WEBPASSWORD=<dein-passwort>`.
- Volumes unverändert wichtig: `/etc/pihole` und `/etc/dnsmasq.d` müssen persistiert werden.
- DHCP im Container: Für DHCP ist `network_mode: host` empfohlen. Bridge-Modus reicht für reines DNS (ohne DHCP).
- Upstream/Unbound: Bei lokalem Unbound-Container übliche Portweiterleitung: 5335.

## Compose Beispiel A: Bridge-Modus (DNS-only)

Datei: `examples/docker-compose.bridge.yml`

- Veröffentlicht Ports 53 (TCP/UDP) und 80 (oder 8080) aus dem Container.
- Kein DHCP (dafür Host-Netz nötig). Gut für die meisten Heim-Setups, bei denen der Router DHCP macht.

Start:

```bash
docker compose -f examples/docker-compose.bridge.yml up -d
```

## Compose Beispiel B: Host-Netz + Unbound (DNS + optional DHCP)

Datei: `examples/docker-compose.host-unbound.yml`

- `network_mode: host` für Pi-hole ermöglicht DHCP-Server und native Bindung an Ports 53/80 des Hosts.
- Unbound läuft separat und exponiert Port 5335 (nur lokal genutzt).

Start:

```bash
docker compose -f examples/docker-compose.host-unbound.yml up -d
```

Hinweise:

- Host-Modus kollidiert, falls bereits andere Dienste Ports 53/80 belegen.
- Für DHCP benötigt der Container ausreichende Capabilities (NET_ADMIN) und Host-Netz.

## Migration v5 -> v6 Schritt für Schritt

1) Backup anlegen (Teleporter oder Volume-Sicherung):
 - Web-UI: Settings → Teleporter (recommended)
 - Oder Volumes `/etc/pihole` und `/etc/dnsmasq.d` sichern.
2) Container stoppen und entfernen: `docker compose down`
3) Compose-Datei auf v6 aktualisieren (siehe Beispiele):
 - `image: pihole/pihole:latest`
 - `WEBPASSWORD` setzen
 - Ports/Volumes prüfen
4) Container neu starten: `docker compose up -d`
5) Prüfen:
 - `docker logs pihole -f` für Fehler
 - Admin UI: `http://<host-ip>/admin/` (oder `:8080`)
 - `dig @<host-ip> pi.hole`
6) Optional: Unbound-Container hinzufügen und in Pi-hole als Upstream `127.0.0.1#5335` konfigurieren.

## Nützliche Tipps

- Bind-Port 80 → 8080 ändern, wenn 80 bereits belegt ist (z. B. NAS/Reverse Proxy).
- Für IPv6: Stelle sicher, dass der Docker-Host korrektes IPv6-Routing hat, oder DNSv6 im Zweifel deaktivieren.
- Log-Größe kontrollieren und MAXDBDAYS begrenzen, um Ressourcen zu sparen.

Weitere Details siehe Compose-Beispiele im Ordner `examples/`.
