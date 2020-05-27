# Automated Kiosk Instalation Script
## This is a full automated KIOSK instalation script for RaspberryPi and UbuntuServer
##### This script was made for working in headless linux environment

**Installing Kiosk:**
1. Clone the repo:
```
git clone https://github.com/matiri132/kioskScript
```
2. Give execution permissions:
```
sudo chmod 740 kioskMode.sh
```
3. Update / upgrade
```
sudo apt update
sudo apt upgrade
```
4. Setup:
-You can choose some parameters in the kioskMode.sh file all are listed at the begining of the file, so you can change it with nano.
-For RaspberryInstalation you can change the files/config.txt file for Audio/Video configurations see [Rpi Documentation](https://www.raspberrypi.org/documentation/configuration/config-txt/)

5. Install (with SUDO):
```
sudo ./kioskMode.sh USER install all
```
-Replace USER by your current user (you can create a new one for kiosk).
-if you use instal all the script will install all necesary packages.
-If you make any changes in the installation file (as kiosk homepage) you only need to use install and reboot.
6. Uninstall (IN DEVELOPMENT):
```
sudo ./kioskMode.sh USER uninstall
```
-USER must be the same user thats run install before.
-RIGTH NOW UNINSTALL ONLY REMOVE THE SERVICE THAT HANDLE KIOSK BUT DONT REVERT TO A HEADLESS LINUX AGAIN, SO CAREFULL!.

