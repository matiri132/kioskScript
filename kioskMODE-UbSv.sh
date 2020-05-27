#!/bin/bash
HOME_URL='http\:\/\/www\.youtube\.com'
H_USER=$1
WD=$(pwd)

install_packages (){
	echo "INSTALLING DEPENDENCIES..."
	#Installing graphical interface
	apt-get install xserver-xorg 
	apt-get install xfce4 xfce4-terminal
	apt-get install lightdm --yes
	apt-get install plymouth plymouth-themes --yes
	apt-get install pix-plym-splash --yes
	#We will install KIOSK en chromium
	apt-get install --no-install-recommends chromium-browser  --yes
	#Install other packages required
	apt-get install xdotool unclutter sed --yes
	apt-get clean --yes
	apt-get autoremove --yes
}
	
}

case $2 in
	install)
		#Install required packages
		if [ $3 == 'full' ]
		then
			install_packages
		fi
	
		#Creating service to handle kiosk
		cp ${WD}/files/kioskusv.conf ${WD}/kioskusv.conf
		sed -i "s/USER/${H_USER}/g" ${WD}/kioskusv.conf

        mkdir /etc/systemd/system/getty@tty1.service.d/
        cp ${WD}/kioskusv.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf 
        systemctl enable getty@tty1.service
		
        cp ${WD}/kiosk.service /etc/systemd/system/kiosk.service
		rm kiosk.service
		cp ${WD}/files/kiosk.sh /home/${H_USER}/kiosk.sh
		systemctl start kiosk
		systemctl enable kiosk
        usermod -a -G audio ${H_USER}
        usermod -a -G video ${H_USER}
		
	;;
	uninstall)
		echo "Removing service..."
		systemctl stop kiosk
		systemctl disable kiosk
		rm	/etc/systemd/system/multi-user.target.wants/kiosk.service
		rm /etc/systemd/system/kiosk.service
		rm /home/${H_USER}/kiosk.sh
	;;
esac

if [ $1 == 'help' ]
then
	echo "This script configure KIOSK mode on RaspberryPi"
	echo "USE:"
	echo "	kioskMode pi install full-> on RPi headless (install graphic mode) "
	echo "	kioskMode pi install -> if have already downloaded graphic environment"
	echo "	kioskMode pi uninstall -> remove service that handle kioskMode"
fi