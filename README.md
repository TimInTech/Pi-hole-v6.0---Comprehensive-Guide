![Pi-hole v6.0 Dashboard](https://github.com/user-attachments/assets/b0ad4d03-d118-4781-8dce-0a9956a978f2)  
# Pi-hole v6.0 - Comprehensive Guide

![Pi-hole v6.0](https://github.com/TimInTech/Pi-hole-v6.0---Comprehensive-Guide/blob/main/image.png)

This repository provides an extensive guide for setting up **Pi-hole v6.0** with detailed configurations, optimizations, and best practices.

## 📌 Related Setup: Pi-hole + Unbound + PiAlert
For an extended setup including **Unbound as a local DNS resolver** and **PiAlert for network monitoring**, check out:

➡ **[Pi-hole + Unbound + PiAlert Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup)**

This guide includes:
- **Step-by-step installation** of Pi-hole, Unbound, and PiAlert
- **Optimized DNS settings** for better performance
- **Network monitoring** with PiAlert for device detection
- **Advanced configurations** for privacy and security

---

# Installation Guide

## 1️⃣ Installing Pi-hole
Pi-hole filters DNS requests to block advertisements across the network.

### Installation on Ubuntu/Debian
```bash
curl -sSL https://install.pi-hole.net | bash
```
Follow the installation prompts and note down your web interface login credentials.

### Accessing the Web Interface
- Open: `http://pi.hole/admin`
- Or replace `pi.hole` with your Pi-hole server’s IP address.

### Post-Installation Configuration
Update block lists and rules:
```bash
pihole -g
```
Ensure Pi-hole starts automatically at boot:
```bash
sudo systemctl enable pihole-FTL
sudo systemctl restart pihole-FTL
```

---

## 2️⃣ Configuring Pi-hole for Advanced DNS
### Setting Custom Upstream DNS Providers
Navigate to **Settings → DNS** in the Pi-hole admin panel and set your preferred upstream DNS servers. Recommended options:
- **Google**: `8.8.8.8, 8.8.4.4`
- **Cloudflare**: `1.1.1.1, 1.0.0.1`
- **Quad9**: `9.9.9.9, 149.112.112.112`

---

## 3️⃣ Advanced Configuration
### Blocking Additional Ads & Trackers
Enhance your blocking capabilities by adding these lists:
```bash
pihole -a -w https://dbl.oisd.nl/
pihole -g
```

### Configuring Local DNS Records
To define static DNS records for local devices, edit:
```bash
sudo nano /etc/pihole/custom.list
```
Add entries in the following format:
```
192.168.1.10    mydevice.local
```
Restart Pi-hole after saving:
```bash
pihole restartdns
```

---

## 4️⃣ Monitoring & Logs
### Viewing Query Logs
Check the latest queries processed by Pi-hole:
```bash
pihole -t
```

### Analyzing Blocked Domains
For an overview of blocked domains:
```bash
pihole -c
```

---

## 5️⃣ Troubleshooting
### Checking Pi-hole Status
To verify Pi-hole is running correctly:
```bash
pihole status
```

### Restarting Pi-hole
```bash
sudo systemctl restart pihole-FTL
```

### Checking Log for Errors
```bash
sudo tail -f /var/log/pihole.log
```

---

## 6️⃣ Additional Resources
For an extended configuration including **Unbound as a recursive DNS resolver** and **PiAlert for security monitoring**, check out:
➡ **[Pi-hole + Unbound + PiAlert Setup](https://github.com/TimInTech/Pi-hole-Unbound-PiAlert-Setup)**

This setup provides:
✔ **Ad-blocking (Pi-hole)** for a cleaner browsing experience
✔ **Network monitoring (Pi.Alert)** for better control
✔ **Independent DNS resolution (Unbound)** for privacy

---

## 📌 Tags:
Pi-hole, Ad Blocker, DNS Filtering, Network Security, Self-hosted DNS, Linux, Ubuntu, Firewall, DNSSEC, Unbound, PiAlert


