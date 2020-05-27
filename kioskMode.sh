#!/bin/bash
HOME_URL='http\:\/\/www\.youtube\.com'
H_USER=$1
WD=$(pwd)

install_packages (){
	echo "INSTALLING DEPENDENCIES..."
	#Installing graphical interface
	apt-get install xserver-xorg 
	#apt-get install x11-xserver-utils xinit --yes
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

case $2 in
	install)
		#Install required packages
		if [ $3 == 'full' ]
		then
			install_packages
		fi
		#Activating graphical interface from raspi-config
		if [ -e /etc/init.d/lightdm ]
		then
          		systemctl set-default graphical.target
          		ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
          		cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${H_USER} --noclear %I \$TERM
EOF
					sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=${H_USER}/"
					#Disable Raspi-Config at boot
					if [ -e /etc/profile.d/raspi-config.sh ]; then
						rm -f /etc/profile.d/raspi-config.sh
			    		if [ -e /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf ]; then
							rm /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf
    					fi
			    		telinit q
					fi
        		else
					echo "You need to install LigthDM. Run :"
					echo "	sudo kioskMode.sh pi install full"
					echo "Change pi if you have another user name (echo \$USER)"
					exit
		fi

		#Set video preferences
		rm -f /boot/config.txt
		cp ${WD}/files/config.txt /boot/config.txt
		#Set Splash
		cp ${WD}/files/splash.png /usr/share/plymouth/themes/pix
		cp ${WD}/files/splash.png /home/${H_USER}/images/Pictures/
		rm -f /usr/share/plymouth/themes/pix/pix.script
		cp ${WD}/files/plymouth /usr/share/plymouth/themes/pix/pix.script
		rm -f /boot/cmdline.txt
		cp ${WD}/files/cmdline /boot/cmdline.txt
		#"No Desktop"
		sed -i "s/true/false/g" /home/${H_USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
		sed -i "s/\/usr\/share\/images\/desktop\-base\/desktop\-background\/\/home\/${H_USER}\/Pictures\/"
		#Creating service to handle kiosk
		cp ${WD}/files/kiosk.service ${WD}/kiosk.service
		sed -i "s/USER/${H_USER}/g" ${WD}/kiosk.service
		sed -i "s/HOMEPAGE/${HOME_URL}/g" ${WD}/kiosk.service
		cp ${WD}/kiosk.service /etc/systemd/system/kiosk.service
		rm kiosk.service
		cp ${WD}/files/kiosk.sh /home/${H_USER}/kiosk.sh
		systemctl start kiosk
		systemctl enable kiosk
		#Forcing chromium
		if [ ! -d /home/${H_USER}/.config/chromium/Default ]
		then
			mkdir /home/${H_USER}/.config/chromium/Default
			touch /home/${H_USER}/.config/chromium/Default/Preferences
		fi
		
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