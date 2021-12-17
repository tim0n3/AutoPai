#!/bin/bash
echo -e "Change user: pi password\n"
passwd

_tz() {
	echo -e "Set timezone:\n"
	sudo timedatectl set-ntp true 
	sudo timedatectl set-timezone Africa/Johannesburg 
	sudo timedatectl
}

_tls_certificate() {
	echo "Generate the TLS certs and then convert them to IoT compatible version:"
	cd /home/pi/app/
	openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem -nodes -out rsa_cert.pem -subj /CN=unused 
	openssl pkcs8 -topk8 -inform PEM -outform DER -in rsa_private.pem -nocrypt > pkcs8_key
	cat /home/pi/app/rsa_cert.pem
}

_tz
_tls_certificate

echo "--------------------------------------"
echo "--  SYSTEM READY FOR 3-post-install --"
echo "--------------------------------------"