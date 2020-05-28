#!/bin/bash
HOME_URL='http\:\/\/www\.youtube\.com'
H_USER=$1
WD=$(pwd)

install_packages (){
	echo "INSTALLING DEPENDENCIES..."
	
	#Installing graphical interface
	apt-get install xserver-xorg -y
	apt-get install lightdm -y
	apt-get install xfce4 xfce4-terminal -y
	apt-get install slim -y
	
	apt-get install plymouth plymouth-themes -y
	apt-get install pix-plym-splash -y
	#We will install KIOSK en chromium
	apt-get install --no-install-recommends chromium-browser  -y
	#Install other packages required
	apt-get install xdotool unclutter sed -y
	apt-get clean -y
	apt-get autoremove -y
}


uninstall_packages (){
	echo "UNINSTALLING GRAPHIC ENVIRONMENT..."
	#Installing graphical interface
	apt-get purge xserver-xorg  -y
	apt-get purge xfce4 xfce4-terminal -y
	apt-get purge lightdm -y
	apt-get purge slim -y
	apt-get purge plymouth plymouth-themes -y
	apt-get purge pix-plym-splash -y
	#We will install KIOSK en chromium
	apt-get purge chromium-browser  -y
	#Install other packages required
	apt-get clean -y
	apt-get autoremove -y
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
		cp ${WD}/files/kiosk.service ${WD}/kiosk.service
		sed -i "s/ARGS/u/g" ${WD}/kiosk.service
		sed -i "s/USER/${H_USER}/g" ${WD}/kiosk.service
		sed -i "s/HOMEPAGE/${HOME_URL}/g" ${WD}/kiosk.service
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
		systemctl set-default multi-user.target
		systemctl stop kiosk
		systemctl disable kiosk
		systemctl stop getty@tty1.service
		systemctl disable getty@tty1.service
		rm	/etc/systemd/system/multi-user.target.wants/kiosk.service
		rm /etc/systemd/system/kiosk.service
		rm /home/${H_USER}/kiosk.sh
		if [ $3 == 'full' ]
		then
			uninstall_packages
		fi
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