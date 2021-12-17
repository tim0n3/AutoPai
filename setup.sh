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
	read -n1 -p "Is this a Pi or a Moxa? (y/n) :" ispi
	if [[ $ispi -eq "y" || $ispi -eq "Y" ]]; then
		echo " Device is Raspberry Pi "
		echo " Using Pi-scripts "
		_is_pi
	else
		echo " Device is Moxa "
		echo "Using Moxa-scripts "
		_is_moxa
	fi
}

_dependancy_install
_start