#!/bin/bash
echo "Creating crontabs:"
cat <<EOF | crontab -
@daily  /sbin/shutdown -r +5
@hourly /bin/bash /home/pi/AutoPai/check-internet.sh
EOF
echo "Crontabs created"
echo "store serialnumber"
sudo bash ./rpi-serialno.sh
echo "Adding this device to the EDS Watchdog RMM under the group EDS - RPi's"
(wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-check-certificate -O ./meshinstall.sh || wget "https://the-eye.forbes.org.za/meshagents?script=1" --no-proxy --no-check-certificate -O ./meshinstall.sh) && chmod 755 ./meshinstall.sh && sudo -E ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr' || ./meshinstall.sh https://the-eye.forbes.org.za 'T19tGvRmxny60A6YZk8ADLgMNvS9b215LGR4RTPh27CmSe2wklnnjN7Dso6l@7Fr'
echo -e "remember to paste your rsa cert into IoT Core\n"
cat /home/pi/app/rsa_cert.pem & sleep 10
echo -e "and remember to update the parameters of the config.json and iot-core-config.json files respectively!!!\n"
echo -e "\nDone!\n"
echo "
Some useful commands for the modem software:
restart the main service:
sudo systemctl restart energydrive.service 

restart the watchdog service:
sudo systemctl restart watchdog.service 

view all the running services on the Pi:
systemctl list-units --type service | grep running

View journal output of the main modem service:
sudo journalctl -f -u energydrive.service

"
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