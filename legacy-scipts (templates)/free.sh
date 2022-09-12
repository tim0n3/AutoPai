#!/bin/bash
FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
if [[ $FREE -lt 2097152 ]]; then               # 10G = 10*1024*1024k
     echo less than 2GBs free! >> /root/free.log
     find /var/log -type f -iname '*log' -print0 | xargs -0 truncate -s0
fi;
