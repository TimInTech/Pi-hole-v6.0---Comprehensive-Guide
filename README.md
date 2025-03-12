![Pi-hole v6.0 Dashboard](https://github.com/user-attachments/assets/b0ad4d03-d118-4781-8dce-0a9956a978f2)  
# Pi-hole v6.0 - Comprehensive Guide

![Pi-hole v6.0](https://github.com/TimInTech/Pi-hole-v6.0---Comprehensive-Guide/blob/main/image.png)

Pi-hole v6.0 introduces significant improvements over previous versions, enhancing performance, domain filtering, and API integration for better management.

---

## 📌 Related Setup: Pi-hole + Unbound + PiAlert
For an extended setup including **Unbound as a local DNS resolver** and **PiAlert for network monitoring**, check out:

➡ **[Pi-hole + Unbound + PiAlert Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup)**

This guide includes:
- **Step-by-step installation** of Pi-hole, Unbound, and PiAlert
- **Optimized DNS settings** for better performance
- **Network monitoring** with PiAlert for device detection
- **Advanced configurations** for privacy and security

---

## 🚀 What's New in Pi-hole v6.0?
- **Embedded Web Server & REST API** – No need for lighttpd, simplifying installation.
- **Advanced Filtering & Custom Domain Handling** – Greater control over allowed and blocked content.
- **Optimized Memory Management in pihole-FTL** – Reduced RAM usage and faster query resolution.
- **Real-time DNS Analysis** – Improved transparency and reporting.
- **New API Backend** – Enables deeper automation and integrations.
- **Enhanced User Management** – Improved role-based access control.
- **Better IPv6 Support** – Optimized handling of IPv6 DNS queries.
- **Extended Logging Features** – More debugging and monitoring options.
- **Support for Local DNS Entries** – Custom domain management for internal networks.
- **Faster Query Responses via Optimized DNS Caching** – Reduced latency for frequently accessed domains.

---

## 🛠 Installation Guide

### Debian/Ubuntu Manual Installation
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl -y
curl -sSL https://install.pi-hole.net | bash
```

### Docker with Dual-Stack Support
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
      TZ: 'America/New_York'
      WEBPASSWORD: 'yourpassword'
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

---

## 📜 Blocklists: Overview and Evaluation

### ✅ Recommended Blocklists (Balanced, minimal false positives)
- [StevenBlack Unified List](https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts)
- [OISD Basic](https://dbl.oisd.nl/)
- [1Hosts (Lite)](https://o0.pages.dev/)
- [AdGuard DNS Filter](https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt)

### 🛠️ Blocklist Tips
```bash
pihole -g  # Update blocklists
pihole -a -b example.com  # Add blocklist manually
```

---

## 📜 Whitelist Management

### 🖥️ Using the Web Interface
- Open `http://<server-ip>/admin`
- Navigate to **Whitelist**
- Add the desired domain (e.g., `alexa.amazon.com`)
- Save changes and update blocklists:
```bash
pihole -g
```

### 📟 Using the Command Line
```bash
pihole -w alexa.amazon.com login.microsoftonline.com googleapis.com
```

---

## 🔥 Advanced IPv6 Configuration

### 🌐 DHCPv6 Server Setup
```ini
# /etc/dnsmasq.d/06-ipv6.conf
dhcp-range=::100,::200, constructor:eth0, 64, 12h
dhcp-option=option6:dns-server,[fd00:dead:beef::100]
dhcp-option=option6:domain-search,home.lan
```

### 📊 Dual-Stack Analytics
```sql
SELECT 
  strftime('%Y-%m-%d', datetime(timestamp, 'unixepoch')) AS day,
  COUNT(*) FILTER (WHERE type = 'A') AS ipv4,
  COUNT(*) FILTER (WHERE type = 'AAAA') AS ipv6
FROM queries
GROUP BY day;
```

---

## 🤖 REST API Mastery

### 🔐 JWT Authentication Flow
```bash
# Get access token
curl -X POST https://pi.hole/admin/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"password":"your_web_password"}'
```

### 📈 Automated Reporting Endpoints
| Endpoint                 | Method | Description                          |
|--------------------------|--------|--------------------------------------|
| `/admin/api/summary`     | GET    | 60+ metrics in single JSON response |
| `/admin/api/top_clients` | GET    | Top 10 IPv6/IPv4 requesters         |
| `/admin/api/network`     | PUT    | Update DNS resolvers without restart|

---

## 🛑 Next-Level Blocklist Strategies

### 📌 v6-Enhanced Blocklist Syntax
```text
||ipv6-tracker.example^$dnstype=AAAA
@@||azure.ipv6.microsoft.com^$dnstype=AAAA
```

### 🔄 Blocklist Version Control
```bash
pihole -g --rollback  # Rollback to previous blocklist state
sudo crontab -e       # Set up automated tracking
```
```cron
0 3 * * * /usr/local/bin/pihole -g && cd /etc/pihole && git commit -am "Daily blocklist update"
```

---

## 🛠️ Troubleshooting v6.0

### 🔍 Diagnostic Toolkit
```bash
pihole -c -6  # Check IPv6 query handling
journalctl -u pihole-FTL -f | grep 'API_AUTH'  # Audit API access logs
pihole -t -ex '^.*doubleclick.net$'  # Test regex filtering latency
```

### 🚩 Common IPv6 Pitfalls
1. **RA (Router Advertisement) Conflicts**: Disable competing IPv6 routers:
```bash
sysctl -w net.ipv6.conf.all.accept_ra=0
```
2. **SLAAC vs DHCPv6**: Ensure consistent address assignment method.
3. **DNS64/NAT64 Compatibility**: Add `dns64` to `PIHOLE_DNS_` environment variables.

---

🔗 **Official Resources**
[GitHub Repository](https://github.com/pi-hole/pi-hole) | [v6 Migration Guide](https://docs.pi-hole.net/guides/v6-upgrade/)
**Recommended Hardware**: [Raspberry Pi 4 Kit (8GB)](https://amzn.to/4gXEciT) with NVMe SSD via USB 3.0

![Pi-hole v6 Architecture](https://example.com/path-to-v6-arch-diagram)
