#!/bin/bash
# This script has sudo for all required sudo actions
_run_firewall_setup_script() {
	echo "--------------------------------------"
	echo "--   Configuring Pi Firewall        --"
	echo "--------------------------------------"
	sudo bash ./ufw.sh
}

_static_ip() {
	echo -e "Configuring network settings:\n"
	echo -e "Configuring PLC static network client on iface eth0 and alt connection on iface eth1\n"
	cat <<EOF >> /etc/dhcpcd.conf
	# define static profile
	interface eth0
	static ip_address=192.168.0.200/24
	# define static profile
	interface eth1
	static ip_address=192.168.3.127/24
EOF
}

_modem_service_install() {
	echo "--------------------------------------"
	echo "--   SystemV service install        --"
	echo "--------------------------------------"
	sudo cp /home/moxa/app/energydrive.service /etc/systemd/system/energydrive.service
	sudo cp /home/moxa/app/watchdog.service /etc/systemd/system/watchdog.service
	sudo systemctl enable energydrive.service
	sudo systemctl stop energydrive.service
	sudo systemctl enable watchdog.service
	sudo systemctl stop watchdog.service
}

_run_firewall_setup_script
_create_vdev_mapping
_static_ip
_modem_service_install

echo "--------------------------------------"
echo "--   SYSTEM READY FOR 2-user        --"
echo "--------------------------------------"