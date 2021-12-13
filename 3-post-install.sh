#!/bin/bash
echo -e "remember to paste your rsa cert into IoT Core\n"
cat /home/pi/app/rsa_cert.pem
echo -e "and remember to update the parameters of the config.json and iot-core-config.json files respectively!!!\n"
echo -e "\nDone!\n"
echo "Reboot the Pi now"
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
