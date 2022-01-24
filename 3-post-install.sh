#!/bin/bash
_create_crontabs() {
	echo "--------------------------------------"
	echo "--        Creating crontabs:        --"
	echo "--------------------------------------"
	cat <<EOF | crontab -
	@daily  /sbin/shutdown -r +5
	@hourly /bin/bash /home/pi/AutoPai/check-internet.sh
EOF
	echo "--------------------------------------"
	echo "--        Crontabs created          --"
	echo "--------------------------------------"
}

_record_serialno() {
	echo "--------------------------------------"
	echo "--       Store serialnumber         --"
	echo "--------------------------------------"
	sudo bash ./rpi-serialno.sh
}

_iot_core_reminder() {
	echo "--------------------------------------"
	echo "-- Paste the RSA cert into IoT Core --"
	echo "--------------------------------------"
	cat /home/pi/app/rsa_cert.pem & sleep 10
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

function _post_install_reboot() {
	echo "Reboot the Pi now?" && sleep 2
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
			echo "Script Pi version is complete."
		;;
		* )
			echo Answer Y | y || N | n only ! ;
			_post_install_reboot
		;;
	esac
}

_create_crontabs
_record_serialno
_iot_core_reminder
_controls_key
_post_install_reboot