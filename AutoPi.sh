#!/bin/bash
echo "Set x permission for .sh files in this folder"
chmod +x *.sh
sudo bash ./0-preinstall.sh
bash ./1-setup.sh
sudo runuser -u pi bash ~/AutoPai/2-user.sh
sudo runuser -u pi bash ~/AutoPai/3-post-install.sh
echo "--------------------------------------"
echo "-- AutoPi has completed autoconfigs --"
echo "--------------------------------------"