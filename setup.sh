#!/bin/bash

_dependancy_install() {
	echo "Installing git to clone the AutoPai repo"
	sudo apt update -yqq ;
	sudo apt install git -yqq ;
	git clone https://github.com/tim0n3/AutoPai.git ;
	cd AutoPai ;
	chmod +x *.sh ;
}

_is_pi() {
	echo "running AutoPi.sh and linked scripts"
	bash 1.10-rc1-ubuntu.sh
}

_is_moxa() {
	echo "Moxa's aren't support due to python wheels compilation requirements."
}
function _os_check() {
	echo "Checking if using the correct distro:"
	distribution=$(egrep '^(NAME)=' /etc/os-release)
    codename=$( egrep '^(VERSION)=' /etc/os-release)
    if [[ ! $distribution =~ ^(Debian|Ubuntu)$ ]]; then
        echo_error "Your distribution ($distribution) is not supported. Swizzin requires Ubuntu or Debian."
        exit 1
    fi
    if [[ ! $codename =~ ^(buster|Focal|bullseye|Jammy)$ ]]; then
        echo_error "Your release ($codename) of $distribution is not supported."
        exit 1
    fi
}

function _start() {
	_os_check
	read -n1 -p "Is this a Pi or a Moxa? (y=Pi/n=moxa) (y/n) :" ispi
	case ${ispi:0:1} in
		y|Y )
			echo " Device is Raspberry Pi "
			echo " Using Pi-scripts "
			_is_pi
		;;
		n|N )
			echo " \n Device is Moxa \n"
			echo "Using Moxa-scripts \n"
			_is_moxa
		;;
		* )
			echo Answer Y | y || N | n only ;
			_start
		;;
	esac
}

_dependancy_install
_start