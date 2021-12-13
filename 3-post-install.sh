#!/bin/bash
echo -e "remember to paste your rsa cert into IoT Core\n"
cat /home/pi/app/rsa_cert.pem
echo -e "and remember to update the parameters of the config.json and iot-core-config.json files respectively!!!\n"
echo -e "\nDone!\n"
echo "Reboot the Pi now"
echo "Rebooting the Pi now"
echo "going down in 30..." && wait 10
echo "going down in 20..." && wait 10
echo "going down in 10..." && wait 5
echo "going down in 5..." && wait 1
echo "going down in 4..." && wait 1
echo "going down in 3..." && wait 1
echo "going down in 2..." && wait 1
echo "bye bye" && wait 1
sudo reboot now
