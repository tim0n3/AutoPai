#!/bin/bash
# This script has permissions for all required actions
_run_firewall_setup_script() {
	echo "--------------------------------------"
	echo "--   Configuring Pi Firewall        --"
	echo "--------------------------------------"
	bash ./ufw.sh
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

function _is_mik() {
	echo -e "Configuring network settings:\n"
	read -n1 -p "Are you using a MikroTik LTE device (y/n):" networksettings
	case ${networksettings:0:1} in
	y|Y )
		echo "Configuring MikroTik static network client on iface eth0"
		cat <<EOF >> /etc/dhcpcd.conf
			# define static profile\n
			interface eth0\n
			# MikroTik eth0 configuration\n
			static ip_address=192.168.88.200/24\n
			static routers=192.168.88.1\n
			static domain_name_servers=192.168.88.1\n
			static domain_name_servers=8.8.8.8\n
EOF
		;;
		n|N )
		echo "configuring eth0 iface for Modbus TCP with ip 192.168.0.200\n"
		cat <<EOF >> /etc/dhcpcd.conf
			# define static profile
			interface eth0
			static ip_address=192.168.0.200/24
EOF
		;;
		* )
			echo Answer Y | y || N | n only ;
			_is_mik
    	;;
	esac
}

_modem_service_install() {
	read -n1 -p "Install modem & watchdog service? (y/n):" serviceinstall
	case $(serviceinstall:0:1) in
	y|Y| )
		echo "--------------------------------------"
		echo "--   SystemV service install        --"
		echo "--------------------------------------"
		cp /home/pi/app/energydrive.service /etc/systemd/system/energydrive.service
		cp /home/pi/app/watchdog.service /etc/systemd/system/watchdog.service
		systemctl enable energydrive.service
		systemctl stop energydrive.service
		systemctl enable watchdog.service
		systemctl stop watchdog.service
	;;
	n|N| )
		echo "You've opted to install the services later"
	;;
	esac
}

_run_firewall_setup_script
_create_vdev_mapping
_is_mik
_modem_service_install

echo "--------------------------------------"
echo "--   SYSTEM READY FOR 2-user        --"
echo "--------------------------------------"
