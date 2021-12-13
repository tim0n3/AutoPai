#!/bin/bash
sudo bash 0-preinstall.sh
bash 1-setup.sh
sudo runuser -u pi bash /home/pi/AutoPai/2-user.sh
sudo runuser -u pi bash /home/pi/AutoPai/3-post-install.sh
echo "--------------------------------------" ;
echo "-- AutoPi has completed autoconfigs --" ;
echo "--------------------------------------" ;
