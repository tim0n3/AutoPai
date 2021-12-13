#!/bin/bash
# This script has sudo for all required sudo actions
echo "--------------------------------------"
echo "--   Configuring Pi Firewall        --"
echo "--------------------------------------"
sudo bash ./ufw.sh
echo -e 'creating virtual device map for usb to serial converters \n'
echo -e 'SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="ttyUSB.EDS"\n' | sudo tee -a /etc/udev/rules.d/99-com.rules
echo -e 'SUBSYSTEM=="tty", ATTRS{idProduct}=="2303", ATTRS{idVendor}=="067b", SYMLINK+="ttyUSB.EDS"\n' | sudo tee -a /etc/udev/rules.d/99-com.rules
echo -e 'SUBSYSTEM=="tty", ATTRS{idProduct}=="6001", ATTRS{idVendor}=="0403", SYMLINK+="ttyUSB.EDS"\n' | sudo tee -a /etc/udev/rules.d/99-com.rules
sudo udevadm trigger
echo -e "Configuring network settings:\n"
echo "
# define static profile
profile mik_ip
# MikroTik eth0 configuration
static ip_address=192.168.88.200/24
static routers=192.168.88.1
static domain_name_servers=192.168.88.1
static domain_name_servers=8.8.8.8

profile no_mik
# Modbus/TCP eth0 configuration
static ip_address=192.168.0.200/24

# fallback to static profile on eth0
interface eth0
fallback mik_ip
fallback no_mik
"| sudo tee -a /etc/dhcpcd.conf
#### Add some logic to query if you're using an LTE dish (MikroTik) or an LTE hat (waveshare) and then apply the appropriate config
echo "--------------------------------------"
echo "--   SystemV service install        --"
echo "--------------------------------------"
sudo cp /home/pi/app/energydrive.service /etc/systemd/system/energydrive.service
sudo cp /home/pi/app/watchdog.service /etc/systemd/system/watchdog.service
sudo systemctl enable energydrive.service
sudo systemctl stop energydrive.service
sudo systemctl enable watchdog.service
sudo systemctl stop watchdog.service
echo "--------------------------------------"
echo "--   SYSTEM READY FOR 2-user        --"
echo "--------------------------------------"
