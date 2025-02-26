# Pi-hole-v6.0---Comprehensive-Guide
Pi-hole v6.0 introduces significant improvements over previous versions, enhancing performance, domain filtering, and API integration for better management.

![image](https://github.com/user-attachments/assets/b0ad4d03-d118-4781-8dce-0a9956a978f2)


# 🛡️ Pi-hole v6.0 - Comprehensive Guide

Pi-hole v6.0 introduces significant improvements over previous versions, enhancing performance, domain filtering, and API integration for better management.

---

## 🚀 What's New in Pi-hole v6.0?

- **Embedded Web Server & REST API** – `lighttpd` is no longer required, simplifying installation and administration.
- **Advanced Filtering & Custom Domain Handling** – Greater control over allowed and blocked content.
- **Optimized Memory Management in `pihole-FTL`** – Reduced RAM usage and faster query resolution.
- **Real-time DNS Analysis** – Improved transparency and reporting.
- **New API Backend** – Enables deeper automation and integrations.
- **Enhanced User Management** – Improved role-based access control and permissions.
- **Better IPv6 Support** – Optimized handling of IPv6 DNS queries.
- **Extended Logging Features** – More options for debugging and monitoring.
- **Support for Local DNS Entries** – Custom domain management for internal networks.
- **Faster Query Responses via Optimized DNS Caching** – Reduced latency for frequently accessed domains.

🔗 **Recommended Raspberry Pi 4 Hardware & Software:** [Amazon Link](https://amzn.to/4gXEciT)

---

## 🛠 Installation Guide (Without Script)

### 🏗️ **Debian/Ubuntu Manual Installation**

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl -y
curl -sSL https://install.pi-hole.net | bash
```

After installation, access the Pi-hole web interface at `http://<server-ip>/admin`.

### 🐳 **Docker Installation**

```bash
docker run -d --name pihole \
  -e TZ="Europe/Berlin" \
  -e WEBPASSWORD="yourpassword" \
  -v /etc/pihole:/etc/pihole \
  -v /etc/dnsmasq.d:/etc/dnsmasq.d \
  --net=host \
  pihole/pihole:latest
```

For a custom Docker network:

```bash
docker network create pihole_network
docker run -d --name pihole --network pihole_network \
  -e TZ="Europe/Berlin" \
  -e WEBPASSWORD="yourpassword" \
  -v /etc/pihole:/etc/pihole \
  -v /etc/dnsmasq.d:/etc/dnsmasq.d \
  pihole/pihole:latest
```

---

## 📜 Blocklists: Overview and Evaluation

### ✅ **Recommended Blocklists** (Balanced, minimal false positives)
- **StevenBlack Unified List**: `https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts`
- **OISD Basic**: `https://dbl.oisd.nl/`
- **1Hosts (Lite)**: `https://o0.pages.dev/`
- **AdGuard DNS Filter**: `https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt`
- **Energized Basic**: `https://block.energized.pro/basic/formats/hosts.txt`

### ⚠️ **Strict Blocklists (Use with Caution)** (May block useful services)
- **OISD Full**: `https://dbl.oisd.nl/`
- **1Hosts (Pro)**: `https://1hosts.cf/`
- **Lightswitch05 Tracking List**: `https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt`
- **NoTrack List**: `https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt`
- **Energized Ultimate**: `https://block.energized.pro/ultimate/formats/hosts.txt`

### 🛠️ **Adding a Blocklist**
```bash
pihole -a -b https://dbl.oisd.nl/
```
Or directly in the database:
```bash
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled) VALUES ('https://dbl.oisd.nl/', 1);"
pihole -g
```

---

## 📜 Whitelist Management – Allowing Services

To ensure that essential services work properly, manually add domains to the whitelist.

### 🖥️ **1️⃣ Using the Web Interface**
1. Open `http://<server-ip>/admin`
2. Navigate to `Whitelist`
3. Add the desired domain (e.g., `alexa.amazon.com`)
4. Save changes and update blocklists: `pihole -g`

### 📟 **2️⃣ Using the Command Line**
```bash
pihole -w alexa.amazon.com login.microsoftonline.com googleapis.com
```

### 💾 **3️⃣ Directly in `gravity.db`**
For bulk additions:
```bash
sqlite3 /etc/pihole/gravity.db "INSERT OR IGNORE INTO domainlist (domain, enabled, type) VALUES ('alexa.amazon.com', 1, 0);"
```

### ⚙️ **Advanced Whitelist Settings**
- **Regex-Based Allowing**: Define allowed domains using `regex.list`.
- **Specific Subdomain Whitelisting**: `pihole -w sub.example.com`
- **Streaming Service Allowlisting**: If Netflix, Spotify, or YouTube are blocked, check their CDN domains (`cdn.netflix.com`, `spotify.com`, `youtube.com`) and whitelist them.

🚀 **Customize Pi-hole to fit your network needs!**

