# AutoPai
Lite-touch installation:

## Lite-touch-install
AutoPai installer for Debian-based distros that use the apt package manager.

The project's scripts contain the steps I perform to install and configure a fully-functional raspberrypi to log data and push it up to my company's analytics tool - codenamed fulcrum

### Prerequisites:
```
Copy the latest version of the modem software v1.8 or v1.9 with all of the config.json files prepopulated with all of the required parameters e.g. UUID's read/sync thresholds etc...
Copy the service files into the same directory.
Copy the log4j file and create a folder in the app directory called logs (/home/<username>/app/logs/).
Create a device in IoT core and wait until the end of the script to paste the x509-wrapped TLS certificate.
```

### v1.9 0-touch mTCP/over/LTEHat setup
```
git clone https://github.com/tim0n3/AutoPai.git ;\
cd AutoPai ;\
chmod +x *.sh ;\
time sudo bash lteHatRootTCP.sh > ./stout-serial.log 2>&1
```
#### Tail the log
```
cd /home/pi/AutoPai/ ;
tail -f stout-serial.log
```

### v1.10-rc1 0-touch ubuntu setup
```
screen -t setup-script ;\
git clone https://github.com/tim0n3/AutoPai.git ;\
cd AutoPai;\
touch stout-setup.log ;\
time sudo bash 1.10-rc1-ubuntu.sh  >> stout-setup.log 2>&1 
```

`ctrl^ad` to detach the screen
### check script progress:
```
tail -f ./stout-setup.log


The Install + compilation of the python-wheels should take around 30mins depending on how much memory you have and whether you've overclocked or not. <br>
### Install time(s) on Pi4b 8GB @1.5Ghz on ubuntu 20.04.4 LTS:
`
real    50m29.391s
`
<br>
`
user    78m24.459s
`
<br>
`
sys     7m15.955s
`
<br>

Once it ends, you can continue adding the certificate into IoT core and ensuring data is pushing into bigQuery

### I want to support you and the amazing work you're doing:
You can get €20 credits and a VPS from just €2.86/month (€0.005/hour) at [Hetzner](https://hetzner.cloud/?ref=lW5DRok8tHpb).
OR
You can get $100 credits and a VPS (Droplet) from just $5/month ($0.007/hour) at [DigitalOcean](https://m.do.co/c/212bea11424f).

### Donations

If you want to show your appreciation, you can donate via [PayPal](https://www.paypal.com/donate?hosted_button_id=ULMMXE4DLQVZS) . Thanks!
