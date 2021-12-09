#!/bin/bash
# This script must be run with sudo
echo -e "Running 0-preinstall.sh as sudo\n" ;
echo "--------------------------------------" ;
echo "-- Creating RPI swap partition  =1G --" ;
echo "--------------------------------------" ;
swapon --show ;
free -h ;
df -h ;
fallocate -l 1G /swapfile ;
ls -lh /swapfile ;
chmod 600 /swapfile ;
ls -lh /swapfile ;
mkswap /swapfile ;
swapon /swapfile ;
swapon --show ;
free -h ;
cp /etc/fstab /etc/fstab.bak ;
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab ;
cat /proc/sys/vm/swappiness ;
sysctl vm.swappiness=10 ;
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf ;
cat /proc/sys/vm/vfs_cache_pressure ;
sysctl vm.vfs_cache_pressure=50 ;
echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf ;
echo -e "\nInstalling and Updating Base System\n" ;
sudo apt update -y ;
sudo apt upgrade -y ;
sudo apt full-upgrade -y ;
echo -e "\nInstalling Modem Software\n";
sudo apt-cache --generate pkgnames \
| grep --line-regexp --fixed-strings \
  -e vim \
  -e openjdk-8-jdk \
  -e libqmi-utils \
  -e udhcpc \
  -e ntp \
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
| xargs sudo apt install -y ;
# -e ddclient \ ## uncomment this if you want to setup ddclient for non-mik-setups and move this above the last pipe
read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname ;
	echo 127.0.1.1		$nameofmachine >> /etc/hosts ;
echo "--------------------------------------" ;
echo "--   SYSTEM READY FOR 1-setup       --" ;
echo "--------------------------------------" ;
