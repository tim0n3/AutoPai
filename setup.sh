#!/bin/bash
# This script must be run with sudo
function _main() {
	function _os_check() {
	    echo "Checking if using the correct distro:"
	    # Borrowing this check from https://github.com/swizzin/swizzin
	    distribution=$(lsb_release -is)
        codename=$(lsb_release -cs)
        if [[ ! $distribution =~ ^(Ubuntu)$ ]]; then
            echo "Your distribution ($distribution) is not supported. This script requires Debian."
            exit 1
        fi
        if [[ ! $codename =~ ^(focal|jammy)$ ]]; then
            echo "Your release ($codename) of $distribution is not supported."
            exit 1
        fi
    }

    function _run_setup() {
        if [[  $distribution =~ ^(Ubuntu)$ ]]; then
            echo "Your release ($codename) of $distribution is not supported."
            touch /home/pi/AutoPai/stout-setup.log ;\
            time sudo bash /home/pi/AutoPai/ubOS.sh  >> stout-setup.log 2>&1 
            exit 0
        fi
    }
_os_check;
_run_setup;
}
_main;