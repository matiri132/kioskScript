do_boot_behaviour() {
  if [ "$INTERACTIVE" = True ]; then
    BOOTOPT=$(whiptail --title "Raspberry Pi Software Configuration Tool (raspi-config)" --menu "Boot Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
      "B1 Console" "Text console, requiring user to login" \
      "B2 Console Autologin" "Text console, automatically logged in as '$USER' user" \
      "B3 Desktop" "Desktop GUI, requiring user to login" \
      "B4 Desktop Autologin" "Desktop GUI, automatically logged in as '$USER' user" \
      3>&1 1>&2 2>&3)
  else
    BOOTOPT=$1
    true
  fi
  if [ $? -eq 0 ]; then
    case "$BOOTOPT" in
      B1*)
        systemctl set-default multi-user.target
        ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
        rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
        ;;
      B2*)
        systemctl set-default multi-user.target
        ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
        cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
        ;;
      #############
      ############
      ##############
      #############
      ############
      ##############
      #############
      ############
      ##############
      #############
      ############
      ##############
      ###########
      B3*)
        if [ -e /etc/init.d/lightdm ]; then
          systemctl set-default graphical.target
          ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
          rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
          sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/#autologin-user=/"
          disable_raspi_config_at_boot
        else
          whiptail --msgbox "Do 'sudo apt-get install lightdm' to allow configuration of boot to desktop" 20 60 2
          return 1
        fi
        ;;
        ##
      ############
      ##############
      #############
      ############
      ##############
      #############
      ############
      ##############
      #############
      ############
      ##############
      #############
      ############
      ##############
      ###########
      B4*)
        if [ -e /etc/init.d/lightdm ]; then
          systemctl set-default graphical.target
          ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
          cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
          sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=$USER/"
          disable_raspi_config_at_boot
        else
          whiptail --msgbox "Do 'sudo apt-get install lightdm' to allow configuration of boot to desktop" 20 60 2
          return 1
        fi
        ;;
      *)
        whiptail --msgbox "Programmer error, unrecognised boot option" 20 60 2
        return 1
        ;;
    esac
    ASK_TO_REBOOT=1
  fi
}
