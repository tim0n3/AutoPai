#!/bin/bash

sudo bash 0-preinstall.sh
bash 1-setup.sh
runuser -u pi 2-user.sh
runuser -u pi 3-post-install.sh
