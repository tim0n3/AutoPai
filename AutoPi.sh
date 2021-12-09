#!/bin/bash
sudo bash /home/pi/0-preinstall.sh ;
bash /home/pi/1-setup.sh ;
sudo runuser -u pi bash /home/pi/2-user.sh ;
sudo runuser -u pi bash /home/pi/3-post-install.sh ;
echo "--------------------------------------" ;
echo "-- AutoPi has completed autoconfigs --" ;
echo "--------------------------------------" ;
