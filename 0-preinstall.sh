#!/bin/bash

echo -e "Running 0-preinstall.sh as sudo\n"
echo "--------------------------------------"
echo "-- Check for low memory systems <8G --"
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

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo -e "\nInstalling and Updating Base System\n"

sudo apt update -y

sudo apt upgrade -y

sudo apt full-upgrade -y

echo -e "\nInstalling Modem Software\n"

xargs -a pkgs sudo apt-get install -y

echo "--------------------------------------"
echo "--   SYSTEM READY FOR 1-setup       --"
echo "--------------------------------------"
