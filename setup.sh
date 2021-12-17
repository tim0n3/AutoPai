#!/bin/bash

function _dependancy_install() {
	echo "Installing git to clone the AutoPai repo"
	sudo apt install git -y
}

function _is_pi() {
	git clone https://github.com/tim0n3/AutoPai.git ;
	cd AutoPai ;
	chmod +x *.sh ;
	bash AutoPi.sh
}

function _is_moxa() {
	git clone https://github.com/tim0n3/AutoPai.git ;
	cd AutoPai ;
	chmod +x *.sh ;
	bash AutoMoxa.sh
}

function _start() {
	echo "Check if using Pi or moxa:"
	read -n1 -p "Is this a Pi or a Moxa? (y=Pi/n=moxa) (y/n) :" ispi
	case ${ispi:0:1} in
		y|Y )
			echo " Device is Raspberry Pi "
			echo " Using Pi-scripts "
			_is_pi
		;;
		n|N )
			echo " Device is Moxa "
			echo "Using Moxa-scripts "
			_is_moxa
		;;
		* )
			echo Answer Y | y || N | n only
		;;
	esac
}

_dependancy_install
_start