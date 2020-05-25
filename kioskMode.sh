LXDE_P="/etc/xdg/lxsession/LXDE-pi/autostart"
HOMEPAGE="http://www.youtube.com"

echo "INSTALLING DEPENDENCIES..."
#Installing graphical interface
sudo apt install xserver-xorg
#We will use LXDE
sudo apt install lxde-core lxappearance
sudo apt install ligthdm
#We will install KIOSK en chromium
sudo apt install chromium-browser
#Install other packages required
sudo apt install xdotool unclutter x11-xserver-utils


if [ ! -x "$(command -v sed))" ]; then
	echo "Installing SED..."
	sudo apt install sed
fi

#Activating graphical interface
if [ -e /etc/init.d/lightdm ]
then
          sudo systemctl set-default graphical.target
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


echo "lxpanel --profile LXDE-pi" >> "${LXDE_P}"
echo "@pcmanfm --desktop --profile LXDE-pi" >> "${LXDE_P}"
#Edit boot graphical configuration
#Desactivate power managment and blanking screen
echo "@xscreensaver -no-splash" >> "${LXDE_P}"
echo "@point-rpi" >> "${LXDE_P}"
echo "@xset s off" >> "${LXDE_P}"
echo "@xset -dpms" >> "${LXDE_P}"
echo "@xset s noblank" >> "${LXDE_P}"
#Prevent error messages
echo "@sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' ~/.config/chromium/Default/Preferences" >> "${LXDE_P}"
echo "@chromium --noerrdialogs --kiosk ${HOMEPAGE} --incognito" >> "${LXDE_P} "

