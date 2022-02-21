#!/bin/bash
echo "Set x permission for *moxa.sh files in this folder"
chmod +x *.sh
sudo bash ./0-preinstall-moxa.sh
bash ./1-setup-moxa.sh
sudo runuser -u moxa bash ~/AutoPai/2-user-moxa.sh
sudo runuser -u moxa bash ~/AutoPai/3-post-install-moxa.sh
echo "--------------------------------------"
echo "-- AutoMoxa has completed autoconfigs --"
echo "--------------------------------------"