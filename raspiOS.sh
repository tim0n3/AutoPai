#!/bin/bash
# This script must be run with sudo

function _main() {

_swap_file() {
echo -e "Running 0-preinstall.sh as sudo\n"
echo "--------------------------------------"
echo "-- Creating RPI swap partition  =1G --"
echo "--------------------------------------"
swapon --show
free -h
df -h
fallocate -l 1G /swap
ls -lh /swap
chmod 600 /swap
ls -lh /swap
mkswap /swap
swapon /swap
swapon --show
free -h
cp /etc/fstab /etc/fstab.bak
echo '/swap none swap sw 0 0' | tee -a /etc/fstab
cat /proc/sys/vm/swappiness
mv /etc/sysctl.conf /etc/sysctl.conf.bak
cp /home/pi/AutoPai/kerneltweaks/sysctl.conf /etc/
chown root:root /etc/sysctl.conf
sysctl -p
}
_updates_and_upgrades() {
echo -e "\nInstalling and Updating Base System\n"
apt update -y
apt upgrade -y
apt full-upgrade -y
}
_pkgs_cs_ips() {
echo "
Configuring Crowdsec dependancies:
Configuring PPAs
Updating PPAs"
#curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash
apt update
echo -e "\nInstalling Modem Software apt packages\n"
echo -e "\nSetting iptables-persistent prompts to auto-select yes\n"
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
echo "
Installing -> vim
Installing -> openjdk-17-jdk
Installing -> libqmi-utils
Installing -> udhcpc
Installing -> htop
Installing -> ufw
Installing -> screen
Installing -> curl
Installing -> wget
Installing -> p7zip
Installing -> neofetch
Installing -> conntrack
Installing -> mtr
Installing -> aptitude
Installing -> iptables*
Installing -> iptables-converter
Installing -> ipset
Installing -> netfilter-persistent
Installing -> nftables
Installing -> xtables-addons-common
Installing -> xtables-addons-source
Installing -> crowdsec
"
apt-cache --generate pkgnames \
| grep --line-regexp --fixed-strings \
	-e vim \
	-e openjdk-17-jdk-headless \
	-e libqmi-utils \
	-e udhcpc \
	-e htop \
	-e ufw \
	-e screen \
	-e curl \
	-e wget \
	-e p7zip-* \
	-e neofetch \
	-e conntrack \
	-e mtr \
	-e aptitude \
	-e ipset \
	-e netfilter-persistent \
	-e nftables \
	-e ipset \
	-e python3 \
	-e python3-pip \
	-e vnstat \
| xargs apt install -y
}
_rmm_setup() {
echo "--------------------------------------"
echo "--       Adding this device         --"
echo "--     to the EDS Watchdog RMM      --"
echo "--   under the group EDS - RPi's    --"
echo "--------------------------------------"
(wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-check-certificate -O ./meshinstall.sh || wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-proxy --no-check-certificate -O ./meshinstall.sh) && chmod 755 ./meshinstall.sh && sudo -E ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr' || ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr'
}
_create_vdev_mapping() {
echo -e 'creating virtual device map for usb to serial converters \n'
cat <<EOF >> /etc/udev/rules.d/99-com.rules
	SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="ttyUSB.EDS"
	SUBSYSTEM=="tty", ATTRS{idProduct}=="2303", ATTRS{idVendor}=="067b", SYMLINK+="ttyUSB.EDS"
	SUBSYSTEM=="tty", ATTRS{idProduct}=="6001", ATTRS{idVendor}=="0403", SYMLINK+="ttyUSB.EDS"
	SUBSYSTEM=="tty", ATTRS{idProduct}=="ea60", AATTRS{idVendor}=="10c4, SYMLINK+="ttyUSB.EDS"
EOF
udevadm trigger
}
_static_ip() {
echo "configuring eth0 iface for Modbus TCP with ip 192.168.0.200\n"

cat <<EOF >> /etc/dhcpcd.conf
# It is possible to fall back to a static IP if DHCP fails:
# define static profile
profile static_eth0
static ip_address=192.168.0.200/24

# fallback to static profile on eth0
interface eth0
fallback static_eth0
EOF
}
_crontabs() {
	cp /home/pi/AutoPai/debug/inetmonit.sh /root/inetmonit
	cat <<EOF | crontab -
	@daily  /sbin/shutdown -r +5
	*/10 * * * * /root/inetmonit
EOF
}
_fetch_latest_software() {
if [-d ! /home/pi/DataServices || /home/pi/DataServices-main]; then
# Install github ssh=key and bypass check for cloning over ssh
cp dotfiles/deployer /home/pi/.ssh/ ;
mv /home/pi/.ssh/deployer /home/pi/.ssh/id_rsa ;
sudo chown pi:pi -R /home/pi/.ssh/ ;
chmod 400 /home/pi/.ssh/id_rsa ;
cp dotfiles/config /home/pi/.ssh/ ;
chown pi:pi -R /home/pi/.ssh/ ;
# Clone latest build for the modem software arm64 version and copy, move into the app folder and take ownership as user pi 
runuser -u pi git clone git@github.com:epicdev-za/DataServices.git ;
cp -R DataServices /home/pi/ ;
chown pi:pi -R /home/pi/DataServices ;
runuser -u pi cp /home/pi/DataServices /home/pi/app ;
fi
}
_modem_service_install() {
echo "--------------------------------------"
echo "--   SystemV service install        --"
echo "--------------------------------------"
runuser -u pi cp bin/python_3.9_6b_raspbian.zip /home/pi/;
runuser -u pi unzip python_3.9_6b_raspbian.zip ;
runuser -u pi sudo cp /home/pi/AutoPai/depends/datacollector.service /etc/systemd/system/datacollector.service ;
runuser -u pi sudo cp /home/pi/AutoPai/depends/datauploader.service /etc/systemd/system/datauploader.service ;
systemctl enable datacollector ;
systemctl stop datacollector ;
systemctl enable datauploader ;
systemctl stop datauploader ;
}
_setup_firewall() {
cat config/iptables/rules.v4 > /etc/iptables/rules.v4
}
_ddos_firewall_rules() {
echo -e "IP Tables Anti-DDoS rules will be configured now.\n"
echo -e "# Raw Rules:\n"
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL ALL -m comment --comment "xmas pkts (xmas portscanners)" -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL NONE -m comment --comment "null pkts (null portscanners)" -j DROP
iptables -t raw -A PREROUTING -s 105.23.225.106/32 -m comment --comment "quickAllow EDS office" -j ACCEPT
iptables -t raw -A PREROUTING -s 165.255.239.57/32 -m comment --comment "quickAllow EDS office fail-over" -j ACCEPT
iptables -t raw -A PREROUTING -s 34.90.83.14/32 -m comment --comment "quickAllow EDS RMM" -j ACCEPT
iptables -t raw -A PREROUTING -s 35.246.178.53/32 -m comment --comment "quickAllow EDS Analytics VPN" -j ACCEPT
iptables -t raw -A PREROUTING -s 37.48.118.94/32 -m comment --comment "quickAllow Tim secure IP" -j ACCEPT
iptables -t raw -A PREROUTING -p tcp -m tcp --dport 0 -m comment --comment "TCP Port 0 attack (2 rules)" -j DROP
iptables -t raw -A PREROUTING -p tcp -m tcp --sport 0 -m comment --comment "TCP Port 0 attack" -j DROP
iptables -t raw -A PREROUTING -p udp -m udp --dport 0 -m comment --comment "UDP Port 0 attack (2 rules)" -j DROP
iptables -t raw -A PREROUTING -p udp -m udp --sport 0 -m comment --comment "UDP Port 0 attack" -j DROP
echo -e "# Mangle Rules:\n"
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j DROP
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j DROP
iptables -t mangle -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -t mangle -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j DROP
iptables -t mangle -A INPUT -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j DROP
}
_save_and_reload_firewall_rules() {
netfilter-persistent save && netfilter-persistent reload
}
_ufw_firewall_rules() {
echo -e "# UFW firewall will now be configured:\n"
ufw allow from 105.23.225.106/32 to any port 22 proto tcp comment 'SSH from EDS SeaCOM'
ufw allow from 165.255.239.57/32 to any port 22 proto tcp comment 'SSH from EDS AXXESS'
ufw allow from 192.168.10.0/24 to any port 22 proto tcp comment 'SSH from EDS Office WiFi'
ufw allow from 192.168.88.0/24 to any port 22 proto tcp comment 'SSH from EDS onsiteAccess'
ufw allow from 37.48.118.94/32 to any port 22 proto tcp comment 'SSH from TIM secure IP'
ufw allow from 34.90.83.14/32 to any port 22 proto tcp comment 'SSH from MeshCentral Svr'
ufw allow from 35.246.178.53/32 to any port 22 proto tcp comment 'SSH from GCP VPN'
ufw allow from 192.168.0.0/16 to any comment 'accept anynet local conns'
echo y | ufw enable
echo y | ufw reload
echo -e "UFW firewall has been configured"
}
_list_all_firewall_rules() {
echo "Firewall rules will now be listed"
echo -e "=== NAT ==="; sudo iptables -t nat -S; echo -e "\n=== MANGLE ==="; sudo iptables -t mangle -S; echo -e "\n=== FILTER ==="; sudo iptables -t filter -S; echo -e "\n=== RAW ==="; sudo iptables -t raw -S;
sleep 5;
}
_tz() {
echo -e "Set timezone:\n"
sudo timedatectl set-ntp true 
sudo timedatectl set-timezone Africa/Johannesburg 
sudo timedatectl
}
_controls_key() {
echo "
----------------------------------------------------------
-- Some useful commands for the modem software:         --
-- restart the main service:                            --
-- sudo systemctl restart datacollector.service         --
--                                                      --
-- restart the watchdog service:                        --
-- sudo systemctl restart datauploader.service          --
--                                                      --
-- view all the running services on the Pi:             --
-- systemctl list-units --type service | grep running   --
--                                                      --
-- View journal output of the main modem service:       --
-- sudo journalctl -f -u datacollector.service          --
----------------------------------------------------------
"
}
echo "--------------------------------------"
echo "-- lteHat configuration commencing! --"
echo "--------------------------------------"
_os_check ;
_rmm_setup ;
_create_vdev_mapping ;
#_static_ip ; uncoment to use static IP on eth0 for rs232/485 installations
_updates_and_upgrades ;
_pkgs_cs_ips ;
#_swap_file # uncomment if you'd like a larger swapfile
_tz ;
_fetch_latest_software ;
_modem_service_install ;
#_ddos_firewall_rules ; # Planned obsolescence in favour rules.v4 file format
_setup_firewall ;
_save_and_reload_firewall_rules ;
#_ufw_firewall_rules ;
_list_all_firewall_rules ;
_controls_key ;
exit 0
}
_main ;
