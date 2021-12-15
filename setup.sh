#!/bin/bash
echo "Installing git to clone the AutoPai repo"
sudo apt install git -y
echo "Check if using Pi or moxa:"
read -n1 -p "Is this a Pi or a Moxa? (y/n) :" ispi
if [[ $ispi -eq "y" || $ispi -eq "Y" ]]; then
	echo " Device is Raspberry Pi "
	echo " Using Pi-scripts "
	git clone https://github.com/tim0n3/AutoPai.git ;\
	cd AutoPai ;\
	chmod +x *.sh ;\
	bash AutoPi.sh
else
	echo " Device is Moxa "
	echo "Using Moxa-scripts "
	git clone https://github.com/tim0n3/AutoPai.git ;\
	cd AutoPai ;\
	chmod +x *.sh ;\
	bash AutoMoxa.sh
fi