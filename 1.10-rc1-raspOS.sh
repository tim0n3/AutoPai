#!/bin/bash
# This script must be run with sudo
echo "--------------------------------------"
echo "-- lteHat configuration commencing! --"
echo "--------------------------------------"
function _os_check() {
	echo "Checking if using the correct distro:"
	# Borrowing this check from https://github.com/swizzin/swizzin
	distribution=$(lsb_release -is)
    codename=$(lsb_release -cs)
    if [[ ! $distribution =~ ^(Debian|Ubuntu)$ ]]; then
        echo "Your distribution ($distribution) is not supported. This script requires Ubuntu or Debian."
        exit 1
    fi
    if [[ ! $codename =~ ^(buster|focal|bullseye|jammy)$ ]]; then
        echo "Your release ($codename) of $distribution is not supported."
        exit 1
    fi
}
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
	curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash
	apt update
	echo -e "\nInstalling Modem Software apt packages\n"
	echo -e "\nSetting iptables-persistent prompts to auto-select yes\n"
	echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
	echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
	echo "
Installing -> vim
Installing -> openjdk-8-jdk
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
		-e openjdk-17-jdk \
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
		-e iptables* \
		-e ipset \
		-e netfilter-persistent \
		-e nftables \
		-e xtables-addons-common \
		-e xtables-addons-source \
		-e python3 \
		-e python3-pip \
		-e vnstat \
		-e crowdsec \
	| xargs apt install -y
	echo -e "\nInstalling Modem Software pip3 packages\n"
	echo "
Installing -> backoff==1.11.1
Installing -> flaky==3.7.0
Installing -> pytest==6.2.4
Installing -> cryptography==36.0.1
Installing -> google-api-python-client==2.34.0
Installing -> google-auth-httplib2==0.1.0
Installing -> google-auth==2.3.3
Installing -> google-cloud-pubsub==2.9.0
Installing -> google-cloud-iot==2.3.0
Installing -> grpc-google-iam-v1==0.12.3
Installing -> pyjwt==2.3.0
Installing -> paho-mqtt==1.5.1
Installing -> psutil==5.9.0
Installing -> google-cloud-pubsub==2.9.0
"
	runuser -l pi -c "pip3 install -r /home/pi/AutoPai/depends/requirements.txt"

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
EOF
udevadm trigger
}
_static_ip() {
	echo "configuring eth0 iface for Modbus TCP with ip 192.168.0.200\n"
		cat <<EOF >> /etc/dhcpcd.conf
			# define static profile
			interface eth0
			static ip_address=192.168.0.200/24
EOF
}
_modem_service_install() {
	echo "--------------------------------------"
	echo "--   SystemV service install        --"
	echo "--------------------------------------"
	runuser -u pi sudo cp /home/pi/AutoPai/depends/datacollector.service /etc/systemd/system/datacollector.service ;
	runuser -u pi sudo cp /home/pi/AutoPai/depends/datauploader.service /etc/systemd/system/datauploader.service ;
	systemctl enable datacollector ;
	systemctl stop datacollector ;
	systemctl enable datauploader ;
	systemctl stop datauploader ;
}
_ddos_firewall_rules() {
	echo -e "IP Tables Anti-DDoS rules will be configured now.\n"
	echo -e "# Raw Rules:\n"
	iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL ALL -m comment --comment "xmas pkts (xmas portscanners)" -j DROP
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
	iptables -t raw -A PREROUTING -p icmp -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	iptables -t raw -A PREROUTING -p igmp -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	iptables -t raw -A PREROUTING -p tcp -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	iptables -t raw -A PREROUTING -p udp -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	#iptables -t raw -A PREROUTING -p l2tp -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	#iptables -t raw -A PREROUTING -p gre -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	#iptables -t raw -A PREROUTING -p etherip -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	#iptables -t raw -A PREROUTING -p ospf -m comment --comment "Accept used protocols and drop all others" -j ACCEPT
	iptables -t raw -A PREROUTING -m comment --comment "Drop unused protocols" -j DROP
	echo -e "# Mangle Rules:\n"
	iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
	iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j DROP
	iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j DROP
	iptables -t mangle -A INPUT -m conntrack --ctstate INVALID -j DROP
	iptables -t mangle -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j DROP
	iptables -t mangle -A INPUT -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j DROP
}
_bastion_firewall_rules() {
	iptables -N IN_CUSTOMRULES_TCP
	iptables -N IN_CUSTOMRULES_UDP
	iptables -N IN_CUSTOMRULES_ICMP
	iptables -N IN_CUSTOMRULES_SAFEZONE
	#iptables -N FORWARDING_IN_CUSTOMRULES uncomment if the device is a router/firewall/proxy.
	#iptables -N OUT_CUSTOMRULES uncomment if you require a more complicated ruleset for egress traffic

	# INPUT - Houstbound pkts from the net
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -p tcp -m conntrack --ctstate INVALID,UNTRACKED -m comment --comment "reject invalid pkts" -j REJECT --reject-with icmp-proto-unreachable
	iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j REJECT --reject-with tcp-reset
	iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j REJECT --reject-with tcp-reset
	iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m comment --comment "Jump to pre-safezone chain" -j IN_CUSTOMRULES_TCP
	iptables -A INPUT -p udp -m conntrack --ctstate NEW -m comment --comment "Jump to pre-safezone chain" -j IN_CUSTOMRULES_UDP
	iptables -A INPUT -p icmp -m comment --comment "Jump to pre-safezone chain" -j IN_CUSTOMRULES_ICMP
	iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
	iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
	iptables -A INPUT -j REJECT --reject-with icmp-protocol-unreachable

	# FORWARD - LANbound pkts from the net
	# FORWARD - Netbound pkts from the LAN
	iptables -A FORWARD -p tcp -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "accept established, related pkts" -j ACCEPT
	iptables -A FORWARD -p tcp -m conntrack --ctstate INVALID -m comment --comment "reject invalid pkts" -j REJECT --reject-with icmp-proto-unreachable
	iptables -A FORWARD -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j REJECT --reject-with tcp-reset
	iptables -A FORWARD -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j REJECT --reject-with tcp-reset
	iptables -A FORWARD -s 192.168.0.0/16 -m conntrack --ctstate NEW -j ACCEPT
	iptables -A FORWARD -p tcp -j REJECT --reject-with tcp-reset
	iptables -A FORWARD -p udp -j REJECT --reject-with icmp-port-unreachable
	iptables -A FORWARD -j REJECT --reject-with icmp-protocol-unreachable

	# OUTPUT - Netbound pkts from the host
	iptables -A OUTPUT -i lo -j ACCEPT
	iptables -A OUTPUT -p tcp -m conntrack -ctstate ESTABLISHED,RELATED -m comment --comment "accept established, related pkts" -j ACCEPT
	iptables -A OUTPUT -p tcp -m conntrack --ctstate INVALID -m comment --comment "reject invalid pkts" -j REJECT --reject-with icmp-proto-unreachable
	iptables -A OUTPUT -p tcp ! --syn -m conntrack --ctstate NEW -m comment --comment "DROP new packets that don't present the SYN flag" -j REJECT --reject-with tcp-reset
	iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -m comment --comment "DROP new pkts that have malformed mss values" -j REJECT --reject-with tcp-reset
	iptables -A OUTPUT -m conntrack -ctstate new -m comment --comment "accept new egress pkts" -j ACCEPT
	iptables -A OUTPUT -m comment --comment "Default Policy" -j REJECT --reject-with --icmp-protocol-unreachable

	# Part of INPUT rules
	iptables -A IN_CUSTOMRULES_TCP -p tcp -m tcp --dport 22  -m comment --comment "Allow SSH for safezone IPs" -j IN_CUSTOMRULES_SAFEZONE
	#iptables -A IN_CUSTOMRULES_TCP -p tcp -m tcp --dport 1194  -m comment --comment "Allow OpenVPN-TCP" -j ACCEPT
	iptables -A IN_CUSTOMRULES_TCP -m comment --comment "back to  INPUT" -j RETURN

	# Part of INPUT rules
	iptables -A IN_CUSTOMRULES_UDP --sport 67 --dport 68 -m comment --comment "Allow dhcp" -j ACCEPT
	#iptables -A IN_CUSTOMRULES_UDP --dport 1194 -m comment --comment "accept OpenVPN-UDP" -j ACCEPT
	#iptables -A IN_CUSTOMRULES_UDP --dport 51820 -m comment --comment "accept WireGuard-UDP" -j ACCEPT
	iptables -A IN_CUSTOMRULES_UDP -m comment --comment "back to  INPUT" -j RETURN

	# Part of INPUT rules
	iptables -A IN_CUSTOMRULES_ICMP -p icmp --icmp-type destination-unreachable -m comment --comment " ICMP_DST_UNREACHABLE" -j ACCEPT
	iptables -A IN_CUSTOMRULES_ICMP -p icmp --icmp-type source-quench -m comment --comment "ICMP_SOURCE_QUENCH" -j ACCEPT
	iptables -A IN_CUSTOMRULES_ICMP -p icmp --icmp-type time-exceeded -m comment --comment "ICMP_TIME_EXCEEDED" -j ACCEPT
	iptables -A IN_CUSTOMRULES_ICMP -p icmp --icmp-type parameter-problem -m comment --comment "ICMP_PARAMETER_PROBLEM" -j ACCEPT
	iptables -A IN_CUSTOMRULES_ICMP -p icmp --icmp-type echo-request -m comment --comment "ICMP_ECHO_REQUEST" -j ACCEPT
	iptables -A IN_CUSTOMRULES_ICMP -p icmp --icmp-type echo-reply -m comment --comment "ICMP_ECHO_REPLY" -j ACCEPT
	iptables -A IN_CUSTOMRULES_ICMP -m comment --comment "back to  INPUT" -j RETURN
	iptables -A IN_CUSTOMRULES_ICMP -m comment --comment "paranoid drop rule" -j REJECT --reject-with icmp-protocol-unreachable

	iptables -A IN_CUSTOMRULES_SAFEZONE -s 37.48.118.94/32 -m comment --comment allow-ingress-from-TIM-secure-IP -j ACCEPT
	iptables -A IN_CUSTOMRULES_SAFEZONE -s 105.23.225.106/32 -m comment --comment allow-ingress-from-eds-hq -j ACCEPT
	iptables -A IN_CUSTOMRULES_SAFEZONE -s 165.255.239.57/32 -m comment --comment allow-ingress-from-eds-hq -j ACCEPT
	iptables -A IN_CUSTOMRULES_SAFEZONE -s 34.90.83.14/32 -m comment --comment allow-ingress-from-eds-hq -j ACCEPT
	iptables -A IN_CUSTOMRULES_SAFEZONE -s 35.246.178.53/32 -m comment --comment allow-ingress-from-eds-hq -j ACCEPT
	iptables -A IN_CUSTOMRULES_SAFEZONE -s 192.168.0.0/16 -j ACCEPT
	iptables -A IN_CUSTOMRULES_SAFEZONE -s 10.8.0.0/24 -j ACCEPT
	iptables -A IN_CUSTOMRULES_SAFEZONE -j RETURN
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
function _main() {
	_os_check ;
	_rmm_setup ;
	_create_vdev_mapping ;
	#_static_ip ; uncoment to use static IP on eth0 for rs232/485 installations
	_updates_and_upgrades ;
	_pkgs_cs_ips ;
	#_swap_file # uncomment if you'd like a larger swapfile
	_tz ;
	_modem_service_install ;
	_ddos_firewall_rules ;
	_bastion_firewall_rules ;
	_save_and_reload_firewall_rules ;
	#_ufw_firewall_rules ;
	_list_all_firewall_rules ;
	_controls_key ;
	exit 0
}
_main