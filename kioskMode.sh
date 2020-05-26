HOMEPAGE="http://www.youtube.com"

echo "INSTALLING DEPENDENCIES..."
#Installing graphical interface
apt install xserver-xorg
#We will use LXDE
apt install lxde-core lxappearance
apt install lightdm
#We will install KIOSK en chromium
apt install chromium
#Install other packages required
apt install xdotool unclutter x11-xserver-utils


if [ ! -x "$(command -v sed))" ]; then
	echo "Installing SED..."
	apt install sed
fi

#Activating graphical interface
if [ -e /etc/init.d/lightdm ]
then
          systemctl set-default graphical.target
          ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
          cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
			sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=$USER/"
			#Disable Raspi-Config at boot
			if [ -e /etc/profile.d/raspi-config.sh ]; then
				rm -f /etc/profile.d/raspi-config.sh
			    if [ -e /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf ]; then
					rm /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf
    			fi
			    telinit q
			fi
        else
			echo "Install LIGTHDM..."
			exit
fi

sed -i "s/USER/$USER/g" ${WD}/kiosk.service
cp ${WD}/kioskScript.sh /home/$USER/kioskScript.sh

sudo cp ${WD}/ssidservice /etc/systemd/system/kiosk.service
sudo systemctl start kiosk
sudo systemctl enable kiosk

