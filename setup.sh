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
	bash AutoPi.sh
}

_is_moxa() {
	echo "running AutoMoxa.sh and linked scripts"
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