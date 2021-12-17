#!/bin/bash
_create_crontabs() {
	echo "--------------------------------------"
	echo "--        Creating crontabs:        --"
	echo "--------------------------------------"
	cat <<EOF | crontab -
	@daily  /sbin/shutdown -r +5
	@hourly /bin/bash /home/moxa/AutoPai/check-internet.sh
EOF
	echo "--------------------------------------"
	echo "--        Crontabs created          --"
	echo "--------------------------------------"
}

_iot_core_reminder() {
	echo "--------------------------------------"
	echo "-- Paste the RSA cert into IoT Core --"
	echo "--------------------------------------"
	cat /home/moxa/app/rsa_cert.pem & sleep 10
	echo -e "and remember to update the parameters of the config.json and iot-core-config.json files respectively!!!\n"
	echo -e "\nDone!\n"
}

_controls_key() {
	echo "
	----------------------------------------------------------
	-- Some useful commands for the modem software:         --
	-- restart the main service:                            --
	-- sudo systemctl restart energydrive.service           --
	--                                                      --
	-- restart the watchdog service:                        --
	-- sudo systemctl restart watchdog.service              --
	--                                                      --
	-- view all the running services on the Pi:             --
	-- systemctl list-units --type service | grep running   --
	--                                                      --
	-- View journal output of the main modem service:       --
	-- sudo journalctl -f -u energydrive.service            --
	----------------------------------------------------------
"
}

_post_install_reboot() {
	echo "Reboot the Moxa now?" && sleep 2
	read -n1 -p "(y/n) :" reboot
	case ${reboot:0:1} in
		y|Y )
			echo "Rebooting the Pi now"
			echo "going down in 30..." && sleep 10
			echo "going down in 20..." && sleep 10
			echo "going down in 10..." && sleep 5
			echo "going down in 5..." && sleep 1
			echo "going down in 4..." && sleep 1
			echo "going down in 3..." && sleep 1
			echo "going down in 2..." && sleep 1
			echo "bye bye" && sleep 1
			sudo reboot now
		;;
		n|N )
			echo "Script Moxa version is complete."
		;;
	esac
}

_create_crontabs
_iot_core_reminder
_controls_key
_post_install_reboot