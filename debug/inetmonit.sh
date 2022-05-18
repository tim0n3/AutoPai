#!/bin/bash

# Set target host IP or hostname
TARGET_HOST='8.8.8.8'

count=$(ping -c 3 $TARGET_HOST | grep icmp* | wc -l)

signal=$(qmicli -p -d /dev/cdc-wdm0 --nas-get-signal-strength)
signal_jar=$(java -jar /home/pi/app/DataCollector.jar signal)

if [ $count -eq 0 ]; then
    echo "$(date)" "Target host" $TARGET_HOST "unreachable, Rebooting!" >>/media/tim/inetmonit.log;
    echo "$(date)" "Signal_status pre-netRST $signal" >>/media/tim/inetmonit.log;
    java -jar /home/pi/app/DataCollector.jar restart_modem 3;
    sleep 10;
    echo "$(date)" "Signal_status post-netRST $signal" >>/media/tim/inetmonit.log;

else
    echo "$(date) ===-> OK! " >>/home/pi/inetmonit.log ;
    echo "$(date) ===-> $signal" >>/home/pi/inetmonit.log ;
fi
