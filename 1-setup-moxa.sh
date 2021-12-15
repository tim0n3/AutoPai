#!/bin/bash
# This script has sudo for all required sudo actions
echo "--------------------------------------"
echo "--   Configuring Pi Firewall        --"
echo "--------------------------------------"
sudo bash ./ufw.sh

echo -e "Configuring network settings:\n"
echo "Configuring PLC static network client on iface eth0 and alt connection on iface eth1"
echo "
# define static profile
interface eth0
static ip_address=192.168.0.200/24
# define static profile
interface eth1
static ip_address=192.168.3.127/24
" | sudo tee -a /etc/dhcpcd.conf
echo "--------------------------------------"
echo "--   SystemV service install        --"
echo "--------------------------------------"
sudo cp /home/moxa/app/energydrive.service /etc/systemd/system/energydrive.service
sudo cp /home/moxa/app/watchdog.service /etc/systemd/system/watchdog.service
sudo systemctl enable energydrive.service
sudo systemctl stop energydrive.service
sudo systemctl enable watchdog.service
sudo systemctl stop watchdog.service
echo "--------------------------------------"
echo "--   SYSTEM READY FOR 2-user        --"
echo "--------------------------------------"