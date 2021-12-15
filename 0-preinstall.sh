#!/bin/bash
# This script must be run with sudo
echo -e "Running 0-preinstall.sh as sudo\n"
echo "--------------------------------------"
echo "-- Creating RPI swap partition  =1G --"
echo "--------------------------------------"
swapon --show
free -h
df -h
fallocate -l 1G /swapfile
ls -lh /swapfile
chmod 600 /swapfile
ls -lh /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show
free -h
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
cat /proc/sys/vm/swappiness
sysctl vm.swappiness=10
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
cat /proc/sys/vm/vfs_cache_pressure
sysctl vm.vfs_cache_pressure=50
echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf
echo -e "\nInstalling and Updating Base System\n"
sudo apt update -y
sudo apt upgrade -y
sudo apt full-upgrade -y
echo -e "\nInstalling Modem Software\n"
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
  Installing -> netfilter-persistant
  Installing -> iptables-persistant
"
sudo apt-cache --generate pkgnames \
| grep --line-regexp --fixed-strings \
  -e vim \
  -e openjdk-8-jdk \
  -e libqmi-utils \
  -e udhcpc \
  -e htop \
  -e ufw \
  -e screen \
  -e curl \
  -e wget \
  -e p7zip \
  -e neofetch \
  -e conntrack \
  -e mtr \
  -e aptitude \
  -e iptables-persistent \
  -e netfilter-persistent \
| xargs sudo apt install -y
echo "--------------------------------------"
echo "--       Adding this device         --"
echo "--     to the EDS Watchdog RMM      --"
echo "--   under the group EDS - RPi's    --"
echo "--------------------------------------"
(wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-check-certificate -O ./meshinstall.sh || wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-proxy --no-check-certificate -O ./meshinstall.sh) && chmod 755 ./meshinstall.sh && sudo -E ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr' || ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr'
read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname
	echo 127.0.1.1		$nameofmachine >> /etc/hosts
echo "--------------------------------------"
echo "--   SYSTEM READY FOR 1-setup       --"
echo "--------------------------------------"