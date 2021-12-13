#!/bin/bash
echo "Get RPi Serial number"
cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2 >> /home/pi/serialno.txt
echo "serialnumber is stored in /home/pi/serialno.txt"