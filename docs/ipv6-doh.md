# IPv6 DoH/DoT Bypass (2025)

Konkrete Strategien, um DNS-over-HTTPS (DoH) und DNS-over-TLS (DoT) zu erkennen und einzudämmen – inklusive IPv6-Aspekten.

## Ziele

- Geräte erkennen, die DoH/DoT nutzen (Android/iOS, Chrome, Firefox)
- Häufige DoH/DoT-Endpunkte blockieren (Domains und Ports)
- Netzwerkebene absichern (iptables/nftables) – inkl. Port 853
- Pi-hole-Gruppen und Ausnahmen sinnvoll einsetzen

## Erkennung

- Pi-hole Query Log: Suche nach Domains wie `dns.google`, `cloudflare-dns.com`, `mozilla.cloudflare-dns.com`, `dns.quad9.net`.
- Browser/OS: Prüfe Einstellungen zu „Sichere DNS“ oder „DNS über HTTPS“.
- Paketanalyse: `tcpdump`/`wireshark` auf Port 853 (DoT) oder bekannte DoH-Hosts.

Beispiel (nur Diagnose):

```bash
sudo tcpdump -i any port 853 or host dns.google
```

## Domain-Blocking in Pi-hole

- Füge Blocklisten/Regex hinzu für bekannte DoH-Anbieter:
  - `dns.google`
  - `cloudflare-dns.com`
  - `mozilla.cloudflare-dns.com`
  - `dns.quad9.net`
  - `dns.adguard.com`

- Vorsicht: Manche Geräte/Apps fallen auf alternative Resolver zurück oder verlieren Konnektivität. Teste pro Gruppe/Klient.

## Portsperren (DoT: 853)

DoT nutzt Port 853 (TCP). Blocke ausgehend im LAN, wenn gewünscht:

```bash
sudo iptables -A OUTPUT -p tcp --dport 853 -j REJECT
sudo ip6tables -A OUTPUT -p tcp --dport 853 -j REJECT
```

- nftables (Alternative):

```bash
sudo nft add table inet filter
sudo nft add chain inet filter output { type filter hook output priority 0; }
sudo nft add rule inet filter output tcp dport 853 reject
```

Für Router/Firewalls entsprechend eingehende/weitergeleitete Verbindungen filtern. Bei nftables sinngemäß Regeln in die passende Tabelle/Chain aufnehmen.

## HTTPS (DoH) erschweren

DoH läuft über 443/TCP und ist schwerer pauschal zu blockieren. Möglichkeiten:

- SNI/Domains per DNS blocken (siehe oben) – oft ausreichend.
- TLS Inspection/Proxy im Unternehmensnetz (nicht für Heim-Setup empfohlen).
- Per-Client-Richtlinien: Android-Private-DNS auf „Aus“ oder „Automatisch“ setzen, in Browsern „Sichere DNS“ deaktivieren.

## Pi-hole Gruppen und Ausnahmen

- Erstelle Gruppen (z. B. „Strikt“, „Standard“, „Ausnahme“).
- Ordne DoH-Blocklisten nur der „Strikt“-Gruppe zu.
- Weise kritische Geräte (z. B. Firmenlaptops) in „Ausnahme“ ein.

## IPv6 Besonderheiten

- Stelle sicher, dass Clients Pi-hole auch via IPv6 als DNS benutzen (RA/DHCPv6 entsprechend konfigurieren).
- Blockregeln sowohl für IPv4 als auch IPv6 setzen (iptables/ip6tables oder nftables-Familienregeln).

## Troubleshooting

```bash
# Prüfen, ob Port 853 noch erreicht wird (sollte blockiert sein)
nc -vz dns.google 853 || echo "Port 853 blockiert oder nicht erreichbar"

# DNS-Auflösung gegen Pi-hole testen
dig @<PIHOLE-IP> example.com
```

Notiere Ausnahmen und Beobachtungen. Wenn Apps ausfallen, prüfe, ob eine Whitelist nötig ist oder ob ein lokaler Resolver (Unbound) zuverlässig arbeitet.
