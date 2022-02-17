#cloud-config

# This is the user-data configuration file for cloud-init. By default this sets
# up an initial user called "ubuntu" with password "ubuntu", which must be
# changed at first login. However, many additional actions can be initiated on
# first boot from this file. The cloud-init documentation has more details:
#
# https://cloudinit.readthedocs.io/
#
# Some additional examples are provided in comments below the default
# configuration.

# On first boot, set the (default) ubuntu user's password to "ubuntu" and
# expire user passwords
chpasswd:
  expire: true
  list:
  - ubuntu:ubuntu
  - pi:raspberry

# Enable password authentication with the SSH daemon
ssh_pwauth: true

## On first boot, use ssh-import-id to give the specific users SSH access to
## the default user
#ssh_import_id:
#- lp:my_launchpad_username
#- gh:my_github_username

## Add users and groups to the system, and import keys with the ssh-import-id
## utility
#groups:
#- robot: [robot]
#- robotics: [robot]
#- pi
#
users:
- default
- name: tim
  gecos: tim forbes
#  primary_group: robot
  groups: sudo
  sudo: "ALL=(ALL) NOPASSWD:ALL"
#  ssh_import_id: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbSCqjnYbRkPpSxJMZW//PASL2rPMMdZAdDkNFe77O9 azuread\timforbes@Tim-DellVostro
ssh_authorized_keys:
-  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbSCqjnYbRkPpSxJMZW//PASL2rPMMdZAdDkNFe77O9 azuread\timforbes@Tim-DellVostro
#  lock_passwd: false
#  passwd: $5$hkui88$nvZgIle31cNpryjRfO9uArF7DYiBcWEnjqq7L1AQNN3
- pi
- name: tim
  gecos: tim forbes
#  primary_group: robot
  groups: sudo
  sudo: "ALL=(ALL) NOPASSWD:ALL"
#  ssh_import_id: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbSCqjnYbRkPpSxJMZW//PASL2rPMMdZAdDkNFe77O9 azuread\timforbes@Tim-DellVostro
ssh_authorized_keys:
-  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbSCqjnYbRkPpSxJMZW//PASL2rPMMdZAdDkNFe77O9 azuread\timforbes@Tim-DellVostro
#  lock_passwd: false
#  passwd: $5$hkui88$nvZgIle31cNpryjRfO9uArF7DYiBcWEnjqq7L1AQNN3

## Update apt database and upgrade packages on first boot
package_update: true
#package_upgrade: true

## Install additional packages on first boot
#packages:
#- pwgen
#- pastebinit
#- [libpython2.7, 2.7.3-0ubuntu3.1]
- vim
#- openjdk-8-jdk
- openjdk-17-jdk
- libqmi-utils
- udhcpc
- htop
- ufw
- screen
- curl
- wget
- p7zip-full
- neofetch
- conntrack
- mtr
- aptitude
#- iptables-persistent
#- iptables*
#- iptables-converter
#- ipset
#- netfilter-persistent
#- nftables
#- xtables-addons-common
#- xtables-addons-source
- python3
- python3-pip
- vnstat
- git

## Write arbitrary files to the file-system (including binaries!)
#write_files:
#- path: /etc/default/keyboard
#  content: |
#    # KEYBOARD configuration file
#    # Consult the keyboard(5) manual page.
#    XKBMODEL="pc105"
#    XKBLAYOUT="gb"
#    XKBVARIANT=""
#    XKBOPTIONS="ctrl: nocaps"
#  permissions: '0644'
#  owner: root:root
#- encoding: gzip
#  path: /usr/bin/hello
#  content: !!binary |
#    H4sIAIDb/U8C/1NW1E/KzNMvzuBKTc7IV8hIzcnJVyjPL8pJ4QIA6N+MVxsAAAA=
#  owner: root:root
#  permissions: '0755'

## Run arbitrary commands at rc.local like time
runcmd:
- (wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-check-certificate -O ./meshinstall.sh || wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-proxy --no-check-certificate -O ./meshinstall.sh) && chmod 755 ./meshinstall.sh && sudo -E ./meshinstall.sh https://the-eye.forbes.org.za 'ieBv5DWBKcm9vRVthBZYgNi7b@kP8xsJSrw0pVlzMhsZqOBMw6yqVvkVootz7xIa' || ./meshinstall.sh https://the-eye.forbes.org.za 'ieBv5DWBKcm9vRVthBZYgNi7b@kP8xsJSrw0pVlzMhsZqOBMw6yqVvkVootz7xIa'
#- curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash
#- apt update -y
- git clone https://github.com/tim0n3/AutoPai.git /home/pi/
- git clone https://github.com/tim0n3/AutoPai.git /home/ubuntu/
- git clone https://github.com/tim0n3/AutoPai.git /root/
