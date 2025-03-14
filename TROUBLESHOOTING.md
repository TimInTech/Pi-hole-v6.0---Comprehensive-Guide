🛠️ Pi-hole v6 - Troubleshooting Guide

This guide provides solutions to common issues encountered when using Pi-hole v6, including DNS resolution problems, blocking issues, network conflicts, and performance optimizations.


---

📌 1. DNS Resolution Issues

🔹 Pi-hole is not blocking ads

✅ Solution:

1. Ensure that your device is using Pi-hole as the primary DNS:

nslookup pi.hole

If it fails, your router may be overriding DNS settings. Manually configure your device’s DNS.



2. Restart Pi-hole:

pihole restartdns


3. Check if the blocklists are up-to-date:

pihole -g



🔹 Sites are slow to load / DNS queries take too long

✅ Solution:

1. Check query time:

dig google.com @127.0.0.1 -p 5335


2. Ensure that Unbound or the upstream DNS is responsive.


3. Optimize the cache size in unbound.conf:

cache-max-ttl: 86400
cache-min-ttl: 3600



🔹 Pi-hole is not resolving local domains

✅ Solution:

1. Add local DNS records:

sudo nano /etc/pihole/custom.list

Example entry:

192.168.1.100   myserver.local



2. Restart DNS:

pihole restartdns




---

🔧 2. Whitelisting & Blocklist Issues

🔹 A website is blocked even after whitelisting

✅ Solution:

1. Check if the domain is still blocked:

pihole -q example.com


2. Force Pi-hole to update lists:

pihole restartdns


3. Manually whitelist:

pihole -w example.com



🔹 Blocklists are not updating

✅ Solution:

1. Manually update:

pihole -g


2. Check for errors:

cat /var/log/pihole_updateGravity.log




---

🌍 3. IPv6 & Network Issues

🔹 IPv6 Queries are not being blocked

✅ Solution:

1. Ensure Pi-hole is handling IPv6:

dig AAAA example.com @127.0.0.1 -p 5335


2. If required, force all clients to use IPv4:

pihole -a setdns 192.168.1.2



🔹 Some devices bypass Pi-hole

✅ Solution:

1. Ensure that your router only assigns Pi-hole’s IP as DNS.


2. Block external DNS on the router firewall:

sudo iptables -A OUTPUT -p udp --dport 53 -j REJECT


3. If the device uses DoH/DoT (DNS over HTTPS/TLS), block common DoH servers.




---

🚀 4. Performance & Optimization

🔹 Pi-hole uses too much memory

✅ Solution:

1. Reduce the number of blocklists:

pihole -a -b remove_list_url


2. Reduce FTL cache size in /etc/pihole/pihole-FTL.conf:

MAXDBDAYS=7
DBINTERVAL=60.0



🔹 Reduce Unbound CPU usage

✅ Solution:

1. Optimize the Unbound configuration:

num-threads: 1
msg-cache-size: 4m
rrset-cache-size: 8m




---

🛑 5. Debugging & Logs

🔹 How to check live logs

pihole -t

🔹 Check DNS query logs

cat /var/log/pihole.log | grep example.com

🔹 Enable FTL debugging for deeper analysis

pihole 