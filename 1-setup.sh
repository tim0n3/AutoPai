#!/bin/bash
# This script has sudo for all required sudo actions
function _run_firewall_setup_script() {
	echo "--------------------------------------"
	echo "--   Configuring Pi Firewall        --"
	echo "--------------------------------------"
	sudo bash ./ufw.sh
}

function _create_vdev_mapping() {
	echo -e 'creating virtual device map for usb to serial converters \n'
	echo -e 'SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="ttyUSB.EDS"\n' | sudo tee -a /etc/udev/rules.d/99-com.rules
	echo -e 'SUBSYSTEM=="tty", ATTRS{idProduct}=="2303", ATTRS{idVendor}=="067b", SYMLINK+="ttyUSB.EDS"\n' | sudo tee -a /etc/udev/rules.d/99-com.rules
	echo -e 'SUBSYSTEM=="tty", ATTRS{idProduct}=="6001", ATTRS{idVendor}=="0403", SYMLINK+="ttyUSB.EDS"\n' | sudo tee -a /etc/udev/rules.d/99-com.rules
sudo udevadm trigger
}

function _is_mik() {
	echo -e "Configuring network settings:\n"
	read -n1 -p "Are you using a MikroTik LTE device (y/n):" networksettings
	if [[ $networksettings -eq "y" || $networksettings -eq "Y" ]]; then
		echo "Configuring MikroTik static network client on iface eth0"
		echo "
			# define static profile\n
			interface eth0\n
			# MikroTik eth0 configuration\n
			static ip_address=192.168.88.200/24\n
			static routers=192.168.88.1\n
			static domain_name_servers=192.168.88.1\n
			static domain_name_servers=8.8.8.8\n
			" | sudo tee -a /etc/dhcpcd.conf
	else
		echo "configuring eth0 iface for Modbus TCP with ip 192.168.0.200\n"
		echo "
			interface eth0\n
			static ip_address=192.168.0.200/24\n
			" | sudo tee -a /etc/dhcpcd.conf
	fi
}

function _modem_service_install() {
	echo "--------------------------------------"
	echo "--   SystemV service install        --"
	echo "--------------------------------------"
	sudo cp /home/pi/app/energydrive.service /etc/systemd/system/energydrive.service
	sudo cp /home/pi/app/watchdog.service /etc/systemd/system/watchdog.service
	sudo systemctl enable energydrive.service
	sudo systemctl stop energydrive.service
	sudo systemctl enable watchdog.service
	sudo systemctl stop watchdog.service
}

_run_firewall_setup_script
_create_vdev_mapping
_is_mik
_modem_service_install

echo "--------------------------------------"
echo "--   SYSTEM READY FOR 2-user        --"
echo "--------------------------------------"