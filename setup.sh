#!/bin/bash
# This script must be run with sudo
touch /home/pi/AutoPai/stout-setup.log ;\
time sudo bash /home/pi/AutoPai/1.10-rc1-ubuntu.sh  >> stout-setup.log 2>&1 