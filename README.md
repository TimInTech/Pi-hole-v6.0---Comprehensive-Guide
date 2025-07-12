# Pi-hole v6.0 – Umfassender Leitfaden

![Pi-hole v6.0 Dashboard](https://github.com/user-attachments/assets/b0ad4d03-d118-4781-8dce-0a9956a978f2)

**Letztes Update:** 12. Juli 2025

---

## 🚀 Was ist neu in Pi-hole v6.0?

- **Eingebetteter Webserver & REST API:**  
  Lighttpd und PHP sind Vergangenheit! Die Weboberfläche und die API laufen direkt im pihole-FTL-Binary.

- **Modernisierte Weboberfläche:**  
  Komplett neues, responsives Design und verbesserte Bedienbarkeit.

- **Filter-Engine 2.0:**  
  Neue Regex-Engine, bessere Performance bei Blocklisten, detaillierte Analyse der Domain-Hierarchie.

- **Performance-Optimierungen:**  
  Multi-Threading, adaptive Caches, Hardwarebeschleunigung für DNSSEC (z.B. auf Raspberry Pi 4).

- **Dynamische Gravity-Sync:**  
  Blocklisten werden jetzt inkrementell aktualisiert – schneller und ressourcenschonender.

- **IPv6-Support & Analyse:**  
  Dual-Stack-Betrieb, erweiterte Statistiken für IPv4/IPv6-Abfragen.

**Aktuelle Versionen:**  
- FTL: v6.1  
- Web: v6.1  
- Core: v6.0.6

**Offizielle Quellen:**  
- [Pi-hole Blog – Release Notes & Changelog](https://pi-hole.net/blog/2025/03/30/pi-hole-ftl-v6-1-web-v6-1-and-core-v6-0-6-released/)  
- [Ankündigung & Diskussion im Forum](https://discourse.pi-hole.net/t/introducing-pi-hole-v6/75863)

---

## 🛠️ Installation

### Standardinstallation (Raspberry Pi / Debian-basiert)

```bash
sudo apt update && sudo apt upgrade -y
curl -sSL https://install.pi-hole.net | bash
```

- **Statische IP-Adresse empfohlen:**  
  Passe `/etc/dhcpcd.conf` an:
  ```ini
  interface eth0
  static ip_address=192.168.1.100/24
  static routers=192.168.1.1
  static domain_name_servers=192.168.1.1
  ```

- **Reboot nach Änderungen:**
  ```bash
  sudo reboot
  ```

### Docker-Installation

```bash
sudo apt update
sudo apt install docker.io docker-compose -y
docker network create pihole_network
```

**Docker-Run Beispiel:**

```bash
docker run -d --name pihole \
  --network pihole_network \
  -e TZ="Europe/Berlin" \
  -e WEBPASSWORD="DEIN_PASSWORT" \
  -v "$(pwd)/etc-pihole/:/etc/pihole/" \
  -v "$(pwd)/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
  --dns=127.0.0.1 --dns=1.1.1.1 \
  --hostname pi.hole \
  -e VIRTUAL_HOST="pi.hole" \
  -e PROXY_LOCATION="pi.hole" \
  -e ServerIP="127.0.0.1" \
  pihole/pihole:latest
```

**Zugriff:**  
Webinterface: http://pi.hole/admin

### Docker Compose (empfohlen für Fortgeschrittene)

Erstelle eine `docker-compose.yml`:

```yaml
version: '3.7'
services:
  pihole:
    image: pihole/pihole:v6.0
    networks:
      pihole_net:
        ipv4_address: 192.168.1.100
        ipv6_address: fd00:dead:beef::100
    environment:
      TZ: 'Europe/Berlin'
      WEBPASSWORD: 'DEIN_PASSWORT'
      DNSMASQ_LISTENING: 'all'
    volumes:
      - './etc-pihole:/etc/pihole'
      - './etc-dnsmasq.d:/etc/dnsmasq.d'
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
networks:
  pihole_net:
    driver: bridge
    enable_ipv6: true
    ipam:
      config:
        - subnet: 192.168.1.0/24
        - subnet: fd00:dead:beef::/64
```

Starten:
```bash
docker-compose up -d
```

---

## 🧠 Blocklists & Filter

- **Blocklists hinzufügen:**
  ```bash
  sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled) VALUES ('https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts', 1);"
  pihole -g
  ```
- **Whitelist:**
  ```bash
  pihole -w domain.de
  ```
- **Regex-Blocking Beispiel:**
  ```bash
  pihole -regex '(^|\.)(tiktok|instagram|snapchat)\.(com|net)$'
  ```

---

## 🔐 REST API & Automatisierung

- **Authentifizierung via JWT**
- Beispiel: Domain blockieren über API
  ```bash
  curl -X POST https://pi.hole/admin/api/block \
    -H "Authorization: Bearer YOUR_JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"domains": ["tiktok.com"], "comment": "Block TikTok", "list": "default"}'
  ```

---

## 📊 Analysen & Monitoring

- **IPv4/IPv6 Statistiken**  
  Über das Webinterface oder SQL-Abfragen gegen die Queries-DB möglich.
- **Automatisierte Berichte:**  
  Viele neue Endpunkte in `/admin/api/`

---

## 🛡️ Troubleshooting

- **Diagnose-Tools:**
  ```bash
  pihole -c -6
  journalctl -u pihole-FTL -f | grep 'API_AUTH'
  ```
- **Häufige IPv6-Probleme:**  
  - Router Advertisement Konflikte (RA) vermeiden
  - Einheitliche Adressevergabe im Netz (SLAAC/DHCPv6)

**Mehr dazu:** [Troubleshooting Guide](TROUBLESHOOTING.md)

---

## 🔗 Nützliche Links

- [Offizielle Pi-hole Doku](https://docs.pi-hole.net/)
- [Forum: Erfahrungsberichte](https://forum.heimnetz.de/threads/pihole-in-version-6-0-erschienen-mit-eigenem-webserver.6404/)
- [Linuxguides zu Pi-hole 6.0](https://forum.linuxguides.de/index.php?thread/9850-pi-hole-in-der-version-6-wurde-ver%C3%B6ffentlicht/)
- [Digital-Eliteboard: Das ist neu](https://www.digital-eliteboard.com/threads/pi-hole-version-6-kann-ausprobiert-werden-das-ist-neu.526759/)

---

## 🤝 Community

Für Erfahrungsaustausch, Tipps & Support:  
[Offizielles Forum](https://discourse.pi-hole.net/) |  
[Pi-hole Blog](https://pi-hole.net/blog/)

---

**Dieses Projekt ist ein Community-Leitfaden für Pi-hole v6.0. Für spezifische Probleme und offizielle Hilfe nutze bitte die oben genannten Links.**
