#!/bin/bash
# This script must be run with sudo/doas permissions.
_pkgs_cs_ips() {
	echo "
	Configuring Crowdsec dependancies:
	Configuring PPAs
	Updating PPAs"
	curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash
	apt update
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
		Installing -> iptables*
		Installing -> iptables-converter
		Installing -> ipset
		Installing -> netfilter-persistent
		Installing -> nftables
		Installing -> xtables-addons-common
		Installing -> xtables-addons-source
		Installing -> crowdsec
	"
	apt-cache --generate pkgnames \
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
		-e iptables* \
		-e iptables-converter \
		-e ipset \
		-e netfilter-persistent \
		-e nftables \
		-e xtables-addons-common \
		-e xtables-addons-source \
		-e crowdsec \
	| xargs apt install -y --no-install-recommends
}

_pkgs_cs_ips
