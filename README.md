![Pi-hole v6.0 Dashboard](https://github.com/user-attachments/assets/b0ad4d03-d118-4781-8dce-0a9956a978f2)  

🔗 **Official Resources**  
[GitHub Repository](https://github.com/pi-hole/pi-hole) | [v6 Migration Guide](https://docs.pi-hole.net/docker/upgrading/v5-v6/)  
**Recommended Hardware**: [Raspberry Pi 4 Kit (8GB)](https://amzn.to/4gXEciT) with NVMe SSD via USB 3.0

# Pi-hole v6.0: Advanced DNS Sinkhole

> **Looking for a comprehensive setup guide?**  
> Check out **[TimInTech/Pi-hole-Unbound-PiAlert-Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup)** for a step-by-step guide to setting up Pi-hole with Unbound (for DNS over TLS) and PiAlert (for monitoring and alerts).

---

## 🧠 **Intelligent Filtering Engine**

```python
# Example: Custom regex for social media blocking in v6
pihole -regex '(^|\.)(tiktok|instagram|snapchat)\.(com|net)$'
```

- **Context-Aware Blocking**  
  Granular control via regex 2.0 engine supporting negative lookaheads and domain hierarchy analysis.
- **Dynamic Gravity Sync**  
  Blocklists now update incrementally - 70% faster than v5's full-database rewrites.

## ⚡ **Performance Breakthroughs**

- **FTL DNS v3.0**  
  Multi-threaded resolver with adaptive cache (up to 500,000 entries) reduces latency to <15ms for 95% of queries.
- **Hardware-Accelerated Cryptography**  
  ARM64 builds leverage Raspberry Pi 4's NEON extensions for 3x faster DNSSEC validation.

---

## 🛠️ **Installation and Configuration**

### **Installation on Raspberry Pi (Debian-based)**

1. **Update System Packages**  
   Ensure your system is up-to-date:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install Pi-hole**  
   Use the automated installer:
   ```bash
   curl -sSL https://install.pi-hole.net | bash
   ```
   Follow the on-screen instructions to complete the installation.

3. **Set a Static IP Address**  
   To avoid DNS resolution issues, configure a static IP for your Raspberry Pi:
   ```bash
   sudo nano /etc/dhcpcd.conf
   ```
   Add the following lines (adjust according to your network):
   ```ini
   interface eth0
   static ip_address=192.168.1.100/24
   static routers=192.168.1.1
   static domain_name_servers=192.168.1.1
   ```

4. **Configure IPv6 (Optional)**  
   If you use IPv6, ensure privacy extensions are disabled:
   ```bash
   sudo nano /etc/sysctl.conf
   ```
   Add the following line:
   ```ini
   net.ipv6.conf.all.accept_ra=0
   ```

5. **Reboot the System**  
   Apply changes:
   ```bash
   sudo reboot
   ```

---

### **Docker Installation on Debian/Ubuntu**

1. **Install Docker**  
   Install Docker and Docker Compose:
   ```bash
   sudo apt update
   sudo apt install docker.io docker-compose -y
   ```

2. **Create a Docker Network**  
   Set up a dedicated network for Pi-hole:
   ```bash
   docker network create pihole_network
   ```

3. **Run Pi-hole in Docker**  
   Use the following command to start Pi-hole in a Docker container:
   ```bash
   docker run -d --name pihole \
     --network pihole_network \
     -e TZ="America/New_York" \
     -e WEBPASSWORD="encrypted_sha256_hash_here" \
     -v "$(pwd)/etc-pihole/:/etc/pihole/" \
     -v "$(pwd)/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
     --dns=127.0.0.1 --dns=1.1.1.1 \
     --hostname pi.hole \
     -e VIRTUAL_HOST="pi.hole" \
     -e PROXY_LOCATION="pi.hole" \
     -e ServerIP="127.0.0.1" \
     pihole/pihole:latest
   ```

4. **Verify Installation**  
   Check if the container is running:
   ```bash
   docker ps
   ```

5. **Access the Web Interface**  
   Open your browser and navigate to `http://pi.hole/admin` to access the Pi-hole dashboard.

---

### **Docker Compose Setup (Advanced)**

For a more structured setup, use Docker Compose:

1. **Create `docker-compose.yml`**  
   Save the following configuration in a file named `docker-compose.yml`:
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
         WEBPASSWORD: 'encrypted_sha256_hash_here'
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

2. **Start the Container**  
   Run the following command in the directory containing `docker-compose.yml`:
   ```bash
   docker-compose up -d
   ```

3. **Verify and Access**  
   Check the container status and access the web interface as described above.

---

## 📜 **Blocklists: Overview and Evaluation**

### Adding Custom Blocklists

```bash
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled) VALUES ('https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts', 1);"
pihole -g
```

### Additional Blocklist Tips

- **Regular Updates**: Schedule regular updates for your blocklists to ensure they are up-to-date.
  ```bash
  pihole -g
  ```
- **Custom Blocklists**: Create your own blocklists for specific needs.
- **Whitelist Important Domains**: Avoid over-blocking by whitelisting essential domains.

---

## 📜 **Whitelist Management – Allowing Services**

### Whitelisting Domains

```bash
sqlite3 /etc/pihole/gravity.db "INSERT OR IGNORE INTO domainlist (domain, enabled, type) VALUES ('example.com', 1, 0);"
```

- **Specific Subdomain Whitelisting**: `pihole -w sub.example.com`
- **Streaming Service Allowlisting**: If Netflix, Spotify, or YouTube are blocked, check their CDN domains (`cdn.netflix.com`, `spotify.com`, `youtube.com`) and whitelist them.

### Additional Whitelist Tips

- **Monitor Whitelist**: Regularly review your whitelist to ensure it contains only necessary domains.
- **Use Wildcards**: For broader allowances, use wildcard entries (e.g., `*.example.com`).

---

## 🔥 **Advanced IPv6 Configuration**

### DHCPv6 Server Setup

```bash
# /etc/dnsmasq.d/06-ipv6.conf
dhcp-range=::100,::200, constructor:eth0, 64, 12h
dhcp-option=option6:dns-server,[fd00:dead:beef::100]
dhcp-option=option6:domain-search,home.lan
```

### Dual-Stack Analytics

```sql
-- Query IPv6 adoption rates
SELECT 
  strftime('%Y-%m-%d', datetime(timestamp, 'unixepoch')) AS day,
  COUNT(*) FILTER (WHERE type = 'A') AS ipv4,
  COUNT(*) FILTER (WHERE type = 'AAAA') AS ipv6
FROM queries
GROUP BY day;
```

---

## 🤖 **REST API Mastery**

### JWT Authentication Flow

```bash
# Get access token
curl -X POST https://pi.hole/admin/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"password":"your_web_password"}'

# Example: Block TikTok via API
curl -X POST https://pi.hole/admin/api/block \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "domains": ["tiktok.com", "tiktokv.com"],
    "comment": "Social media block",
    "list": "default"
  }'
```

### Automated Reporting Endpoints

| Endpoint                 | Method | Description                          |
|--------------------------|--------|--------------------------------------|
| `/admin/api/summary`     | GET    | 60+ metrics in single JSON response |
| `/admin/api/top_clients` | GET    | Top 10 IPv6/IPv4 requesters         |
| `/admin/api/network`     | PUT    | Update DNS resolvers without restart|

---

## 🛑 **Next-Level Blocklist Strategies**

### v6-Enhanced Blocklist Syntax

```text
# Block IPv6 tracking domains
||ipv6-tracker.example^$dnstype=AAAA

# Allow Microsoft IPv6 endpoints
@@||azure.ipv6.microsoft.com^$dnstype=AAAA
```

### Blocklist Version Control

```bash
# Rollback to previous blocklist state
pihole -g --rollback

# Set up automated git-based tracking
sudo crontab -e
```

```cron
0 3 * * * /usr/local/bin/pihole -g && cd /etc/pihole && git commit -am "Daily blocklist update"
```

---

## 🛠️ **Troubleshooting v6.0**

### Diagnostic Toolkit

```bash
# Check IPv6 query handling
pihole -c -6

# Audit API access logs
journalctl -u pihole-FTL -f | grep 'API_AUTH'

# Test regex filtering latency
pihole -t -ex '^.*doubleclick.net$'
```

### Common IPv6 Pitfalls

1. **RA (Router Advertisement) Conflicts**  
   Disable competing IPv6 routers:  
   `sysctl -w net.ipv6.conf.all.accept_ra=0`
   
2. **SLAAC vs DHCPv6**  
   Ensure consistent address assignment method network-wide

3. **DNS64/NAT64 Compatibility**  
   Add `dns64` to `PIHOLE_DNS_` environment variables

---

## 📌 Troubleshooting & Common Issues
For common Pi-hole v6 issues and solutions, check out the **[Troubleshooting Guide](TROUBLESHOOTING.md)**.