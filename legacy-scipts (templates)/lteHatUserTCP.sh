#!/bin/bash
# This script must be run as pi
_tls_certificate() {
	echo -e "Generate the TLS certs and then convert them to IoT compatible version:\n"
	cd /home/pi/app/
	openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem -nodes -out rsa_cert.pem -subj /CN=unused 
	openssl pkcs8 -topk8 -inform PEM -outform DER -in rsa_private.pem -nocrypt > pkcs8_key
	cat /home/pi/app/rsa_cert.pem
}
_iot_core_reminder() {
	echo "--------------------------------------"
	echo "-- Paste the RSA cert into IoT Core --"
	echo "--------------------------------------"
	echo -e "and remember to update the parameters of the config.json and iot-core-config.json files respectively!!!\n"
	cat /home/pi/app/rsa_cert.pem & sleep 10
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
_reboot() {
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
}

_tls_certificate
_controls_key
_iot_core_reminder
_reboot