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

### Single-line-Installation
Run the command and follow the assistant:
```
wget https://raw.githubusercontent.com/tim0n3/AutoPai/master/setup.sh && bash setup.sh
```
### Manually clone and run the setup file directly
```
git clone https://github.com/tim0n3/AutoPai.git ;\
cd AutoPai ;\
chmod +x *.sh ;\
bash setup.sh
```
### v1.9 0-touch mTCP/over/LTEHat setup
```
git clone https://github.com/tim0n3/AutoPai.git ;\
cd AutoPai ;\
chmod +x *.sh ;\
time sudo bash lteHatRootTCP.sh > ./stout-serial.log 2>&1
```
### v1.10-rc1 0-touch ubuntu setup
```
git clone https://github.com/tim0n3/AutoPai.git ;\
cd AutoPai ;\
chmod +x *.sh ;\
screen -t pipinstalls ;\
time pip3 install -r requirements.txt > ./stout-serial.log 2>&1 ;\
```
`crtl-a+d to detach the screen`
# check pip progress:
```
tail -f ./stout-serial.log
```
real    25m29.391s
user    78m24.459s
sys     7m15.955s
```
#### Tail the log
```
cd /home/pi/AutoPai/ ;
tail -f stout-serial.log
```
### 0-touch mTCP/over/EtherNet
```
Comming soon:
```
### 0-touch RTU/over/232
```
Comming soon:
```
### 0-touch RTU/over/485
```
Comming soon:
```
Once it ends, you can continue adding the certificate into IoT core and ensuring data is pushing into bigQuery

### I want to support you and the amazing work you're doing:
You can get €20 credits and a VPS from just €2.86/month (€0.005/hour) at [Hetzner](https://hetzner.cloud/?ref=lW5DRok8tHpb).
OR
You can get $100 credits and a VPS (Droplet) from just $5/month ($0.007/hour) at [DigitalOcean](https://m.do.co/c/212bea11424f).

### Donations

If you want to show your appreciation, you can donate via [PayPal](https://www.paypal.com/donate?hosted_button_id=ULMMXE4DLQVZS) . Thanks!
