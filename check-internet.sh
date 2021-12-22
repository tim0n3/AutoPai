#!/bin/bash
function _check_internet(){
	ping -c4 www.google.com
	let a=$?
	if [ "$a" != "0" ]; then
	  /sbin/shutdown -r +1 Connection lost, rebooting...
	fi
}
_check_internet