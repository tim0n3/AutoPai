#!/bin/bash
echo -e "IP Tables Anti-DDoS rules will be configured now."
echo "
# Raw Rules:
"
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL ALL -m comment --comment "xmas pkts (xmas portscanners)" -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL NONE -m comment --comment "null pkts (null portscanners)" -j DROP
echo "
# Mangle Rules:
"
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j DROP
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j DROP
echo "
# UFW firewall will now be configured:"
ufw allow from 105.23.225.106/32 to any port 22 proto tcp comment 'SSH from EDS SeaCOM'
ufw allow from 165.255.239.57/32  to any port 22 proto tcp comment 'SSH from EDS AXXESS'
ufw allow from 192.168.10.0/24 to any port 22 proto tcp comment 'SSH from EDS Office WiFi'
ufw allow from 192.168.88.0/24 to any port 22 proto tcp comment 'SSH from EDS onsiteAccess'
ufw allow from 37.48.118.94/32 to any port 22 proto tcp comment 'SSH from TIM secure IP'
ufw allow from 34.90.83.14/32 to any port 22 proto tcp comment 'SSH from MeshCentral Svr'
ufw allow from 34.90.83.14/32 to any port 80 proto tcp comment 'http from MeshCentral Svr'
ufw allow from 34.90.83.14/32 to any port 443 proto tcp comment 'https from MeshCentral Svr'
ufw allow from 34.107.85.58/32 to any comment 'Allow connections from uptimeRobot'
ufw allow from 35.246.178.53/32 to any port 22 proto tcp comment 'SSH from GCP VPN'
ufw allow from 192.168.0.0/16  to any comment 'accept anynet local conns'
ufw enable
ufw reload
echo -e "UFW firewall has been configured"
echo "Firewall rules will now be listed"
echo "--------------------------------------"
echo "--           RAW RULES              --"
echo "--------------------------------------"
iptables -t raw -nvL --line-numbers
echo "--------------------------------------"
echo "--           MANGLE RULES           --"
echo "--------------------------------------"
iptables -t mangle -nvL --line-numbers
echo "--------------------------------------"
echo "--           UFW RULES              --"
echo "--------------------------------------"
ufw status verbose && sleep 5