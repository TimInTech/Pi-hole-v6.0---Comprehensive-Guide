# Router als DNS auf Pi-hole setzen (FRITZ!Box und andere)

Ziel: Alle Clients im Netz 192.168.178.0/24 sollen Pi-hole als primären DNS nutzen. Empfohlene Methode: DNS im Router auf die Pi-hole-IP setzen und keinen sekundären DNS eintragen.

## FRITZ!Box (AVM)

- Empfohlene Vorgehensweise laut Pi-hole: Pi-hole als einziger DNS-Server im Netzwerk.
- Variante A: Pi-hole-DHCP verwenden (für per-Client-Transparenz)
  1. In der FRITZ!Box DHCP deaktivieren: Heimnetz → Netzwerk → Netzwerkeinstellungen → IPv4-Adressen → DHCP-Server deaktivieren
  2. In Pi-hole DHCP aktivieren (z. B. Start: 192.168.178.100, Ende: 192.168.178.200, Router: 192.168.178.1)
- Variante B: DNS in FRITZ!Box setzen (Router behält DHCP)
  1. Heimnetz → Netzwerk → Netzwerkeinstellungen → IPv4-Konfiguration
  2. Lokaler DNS-Server: IP von Pi-hole eintragen (z. B. 192.168.178.2)
  3. Keinen sekundären DNS konfigurieren

Offizielle Doku/Referenzen:

- Pi-hole Discourse – DHCP und „Top Clients“: [Why do I only see my router’s IP… (Top Clients)](https://discourse.pi-hole.net/t/why-do-i-only-see-my-routers-ip-address-instead-of-individual-devices-in-the-top-clients-section-and-query-log/3653)
- Pi-hole Discourse – Pi-hole DHCP: [How do I use Pi-hole’s built-in DHCP server and why?](https://discourse.pi-hole.net/t/how-do-i-use-pi-holes-built-in-dhcp-server-and-why-would-i-want-to/3026)
- Pi-hole Discourse – Rebind-Protection: [Why won’t Pi-hole work with DNS rebind protection enabled?](https://discourse.pi-hole.net/t/why-wont-pi-hole-work-with-dns-rebind-protection-enabled/3142)

## UniFi / Ubiquiti

- Controller → Networks → (LAN) → DHCP Name Server: Pi-hole-IP (z. B. 192.168.178.2)
- „Auto/ISP DNS“ deaktivieren/überschreiben
- Für VLANs jeweils eigene DNS-Einstellung setzen

Docs:

- Ubiquiti Hilfe (UniFi Network) – DHCP/DNS Konfiguration (je nach Version; Suchbegriff: "DHCP Name Server")

## TP-Link (Omada/Archer)

- DHCP-Server → DHCP Settings → Primary DNS: Pi-hole-IP
- Secondary DNS leer lassen

## AsusWRT / Merlin

- WAN → Internetverbindung → DNS-Server-Optionen: Manuell → Primärer DNS: Pi-hole-IP
- Optional: LAN → DHCP Server → DNS Server → Pi-hole-IP

## OpenWrt

- LuCI: Network → Interfaces → LAN → DHCP Server → Advanced → DHCP-Optionen: `6,192.168.178.2`
- Oder: Network → DHCP and DNS → DNS Forwardings → `192.168.178.2`

Docs:

- OpenWrt Wiki – DHCP Option 6 & DNS Forwardings

## Allgemeine Tipps

- Stelle sicher, dass die Pi-hole-IP statisch ist (z. B. 192.168.178.2) und nicht durch DHCP verändert wird.
- Vermeide sekundäre DNS-Server, um Umgehungen zu verhindern.
- Für per-Client-Transparenz: Pi-hole als DHCP-Server betreiben oder Router mit Option 6 (DNS Server) konfigurieren.
- IPv6: Falls aktiv, DNSv6 entsprechend auf Pi-hole setzen oder IPv6-DNS im Router deaktivieren, solange keine saubere Konfiguration möglich ist.
