#!/bin/bash
# This script must be run with sudo
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
	sysctl vm.swappiness=1
	echo 'vm.swappiness=1' | tee -a /etc/sysctl.conf
	cat /proc/sys/vm/vfs_cache_pressure
	sysctl vm.vfs_cache_pressure=50
	echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf
}

_updates_and_upgrades() {
	echo -e "\nInstalling and Updating Base System\n"
	apt update -y
	apt upgrade -y
	apt full-upgrade -y
}

_install_dependancies() {
	echo -e "Configuring Modem Software dependancies:\n"
	read -n1 -p "Would you like to install Crowdsec IPS (y/n):" softwaresettings
	case ${softwaresettings:0:1} in
	y|Y|yes|Yes|YES )
		bash ./0.01-preinstall-install-dependancies.sh
		;;
	n|N|no|No|NO )
		bash ./0.02-preinstall-install-dependancies.sh
		;;
	* )
		echo Answer Y | y || N | n only ! ; 
		_install_dependancies
    	;;
	esac
}

_rmm_setup() {
	echo "--------------------------------------"
	echo "--       Adding this device         --"
	echo "--     to the EDS Watchdog RMM      --"
	echo "--   under the group EDS - RPi's    --"
	echo "--------------------------------------"
	(wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-check-certificate -O ./meshinstall.sh || wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-proxy --no-check-certificate -O ./meshinstall.sh) && chmod 755 ./meshinstall.sh && sudo -E ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr' || ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr'
}

_rename_host() {
	read -p "Please name your machine:" nameofmachine
		echo "Is this hostname correct?" $nameofmachine " (y/n):"
		read answer
		case $answer in
			y|Y|yes|Yes|YES)
				echo $nameofmachine > /etc/hostname
				echo 127.0.1.1		$nameofmachine >> /etc/hosts
			;;
			n|N|no|No|NO)
				echo "Please, try again: "
				_rename_host
			;;
			*)
				echo Answer Y | y || N | n only ! ;
				_rename_host
}

_swap_file
_updates_and_upgrades
_install_dependancies
_rmm_setup
_rename_host

echo "--------------------------------------"
echo "--   SYSTEM READY FOR 1-setup       --"
echo "--------------------------------------"