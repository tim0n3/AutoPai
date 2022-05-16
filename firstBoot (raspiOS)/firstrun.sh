#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
echo template-data-logger >/etc/hostname
sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\ttemplate-data-logger/g" /etc/hosts
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
install -o "$FIRSTUSER" -m 700 -d "$FIRSTUSERHOME/.ssh"
install -o "$FIRSTUSER" -m 600 <(printf "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbSCqjnYbRkPpSxJMZW//PASL2rPMMdZAdDkNFe77O9 azuread\timforbes@Tim-DellVostro") "$FIRSTUSERHOME/.ssh/authorized_keys"
echo 'PasswordAuthentication no' >>/etc/ssh/sshd_config
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'pi' '$5$HKRHqzJVVD$YPs8pz4teIWaGqkG.gsbxaJw8hp/NDO0OhQPozhkoE7'
else
   echo "$FIRSTUSER:"'$5$HKRHqzJVVD$YPs8pz4teIWaGqkG.gsbxaJw8hp/NDO0OhQPozhkoE7' | chpasswd -e
   if [ "$FIRSTUSER" != "pi" ]; then
      usermod -l "pi" "$FIRSTUSER"
      usermod -m -d "/home/pi" "pi"
      groupmod -n "pi" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=pi/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/pi/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /pi /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
systemctl enable ssh
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=ZA
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="EnergyDrive Staff"
	psk=77e14c4e2ac91a46549c4f6ea13bc435d1710e42164380117c7133c86a139f44
}

WPAEOF
chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
rfkill unblock wifi
for filename in /var/lib/systemd/rfkill/*:wlan ; do
  echo 0 > $filename
done
rm -f /etc/localtime
echo "Africa/Johannesburg" >/etc/timezone
dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
dpkg-reconfigure -f noninteractive keyboard-configuration
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
apt update -y
apt install -y vim neofetch udhcpc openjdk-17-jdk-headless htop git ufw screen curl wget conntrack mtr python3 python3-pip
exit 0
