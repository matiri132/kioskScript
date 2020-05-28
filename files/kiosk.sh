#!/bin/bash
xset s noblank
xset s off
xset -dpms

if [ $1 == 'u']
then
    export GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
fi

unclutter -idle 0.5 -root &

sed -i 's/"exited_cleanly": false/"exited_cleanly": true/'   home/pi/.config/chromium/Default/Preferences
sed -i 's/exit_type":"Chrashed"/"exit_type":"Normal"/' home/pi/.config/chromium/Default/Preferences
#/usr/bin/chromium --noerrdialogs --disable-infobars --kiosk ${HOMEPAGE} --incognito &
