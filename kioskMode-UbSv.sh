#!/bin/bash
HOME_URL='http\:\/\/www\.youtube\.com'
H_USER=$1
WD=$(pwd)

install_packages (){
	echo "INSTALLING DEPENDENCIES..."
	
	#Installing graphical interface
	apt-get install xserver-xorg --yes
	apt-get install lightdm --yes
	apt-get install xfce4 xfce4-terminal --yes
	apt-get install slim --yes
	
	apt-get install plymouth plymouth-themes --yes
	apt-get install pix-plym-splash --yes
	#We will install KIOSK en chromium
	apt-get install --no-install-recommends chromium-browser  --yes
	#Install other packages required
	apt-get install xdotool unclutter sed --yes
	apt-get clean --yes
	apt-get autoremove --yes
}
	

case $2 in
	install)
		#Install required packages
		if [ $3 == 'full' ]
		then
			install_packages
		fi

		#"No Desktop"
		sed -i "s/true/false/g" /home/${H_USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
		sed -i "s/\/usr\/share\/images\/desktop\-base\/desktop\-background\/\/home\/${H_USER}\/Pictures\/"
		#Set Splash
		cp ${WD}/files/splash.png /usr/share/plymouth/themes/pix
		cp ${WD}/files/splash.png /home/${H_USER}/images/Pictures/
		rm -f /usr/share/plymouth/themes/pix/pix.script
		cp ${WD}/files/plymouth /usr/share/plymouth/themes/pix/pix.script
		#Creating service to autologin
		systemctl set-default graphical.target
		sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=${H_USER}/"
		cp ${WD}/files/kioskusv.conf ${WD}/kioskusv.conf
		sed -i "s/USER/${H_USER}/g" ${WD}/kioskusv.conf
        mkdir /etc/systemd/system/getty@tty1.service.d/
        cp ${WD}/kioskusv.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf 
        systemctl enable getty@tty1.service
		#Service to handler kiosk
        cp ${WD}/kiosk.service /etc/systemd/system/kiosk.service
		sed -i "s/ARGS/u/g" ${WD}/kiosk.service
		sed -i "s/USER/${H_USER}/g" ${WD}/kiosk.service
		sed -i "s/HOMEPAGE/${HOME_URL}/g" ${WD}/kiosk.service
		rm kiosk.service
		cp ${WD}/files/kiosk.sh /home/${H_USER}/kiosk.sh
		systemctl start kiosk
		systemctl enable kiosk
        usermod -a -G audio ${H_USER}
        usermod -a -G video ${H_USER}
		
	;;
	uninstall)
		echo "Removing service..."
		systemctl set-default multi-user.target
		systemctl stop kiosk
		systemctl disable kiosk
		systemctl stop getty@tty1.service
		systemctl disable getty@tty1.service
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