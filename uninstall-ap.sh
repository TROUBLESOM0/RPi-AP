#!/bin/bash
#
# uninstall-ap.sh v.1
#
echo ""
echo "This will remove all associated files and settings related to RPi-ap"
echo "And will try to revert back to the original files and settings"
echo ""
echo "If an issue occurs, script should provide information on the issue and"
echo "query whether you want to continue or not."
echo ""
echo "----------------------------------------------------------------------"
echo ""
echo "FILE/FOLDER REMOVAL :"
echo "   - /usr/local/etc/RPi-ap/ "
echo "   - RPi-ap-check.service in /etc/systemd/system/ "
echo "   - var/www/html/ login.php and login.data "
echo "   - /etc/hostpad/hostapd.conf "
echo "   - /etc/sudoers.d/010_RPi-ap "
echo ""
echo "FILE/FOLDER RESTORE :"
echo "   - login.php, index.html if existed previosly "
echo "   - dnsmasq.conf in /etc/ "
echo "   - dhcpcd.conf in /etc/ "
echo "   - hostapd.conf in /etc/hostapd/ , only if it existed previously "
echo ""
echo "----------------------------------------------------------------------"
echo ""
echo "This script will query whether user would like to remove:"
echo "  - apache2 "
echo ""
echo "And will automatically try to remove:"
echo "  - unzip,"
echo "  - hostapd,"
echo "  - libapache2-mod-php"
echo ""
echo ""
#
#
### VARIABLES ###
#################
rootdir=/usr/local/etc/RPi-ap
stadir=/usr/local/etc/RPi-ap/sta-ap
req=required
whtml=$stadir/web/index.html
wlogin=$stadir/web/login.php
ap=/var/www/html
service=RPi-ap-check.service
_wpa=/etc/wpa_supplicant
#
### Variables for Removing ###
a=$rootdir/
b=$ap/login.php
c=$ap/login.data
d=$_wpa/wpa_supplicant.conf
e=$ap/index.html
f=/etc/dnsmasq.conf
g=/etc/dhcpcd.conf
h=libapache2-mod-php7.4
hh=libapache2-mod-php7.3
hhh=libapache2-mod-php7.2
j=apache2-doc
k=apache2-bin
#
### Variables for Restoring ###
bk=$stadir/pre-sys-bkup
bb=$ap/login.php.sta-ap.bkup
dd=$d.bkup
ee=$ap/index.html.sta-ap.bkup
ff=$bk/dnsmasq.conf
gg=$bk/dhcpcd.conf
#
#############################################
### sets sleep functions ###
s () { sleep .5; }
s1 () { sleep 1; }
s2 () { sleep 2; }
s3 () { sleep 3; }
s4 () { sleep 4; }
s5 () { sleep 5; }
#
########################
###    ASK_RPI-AP   ###
########################
ask_RPi-ap () {
echo -e "\nRemoving RPi-ap Files..."

if [[ -d $rootdir ]]
then rm -r $rootdir
echo "RPi-ap files removed"
else echo "Unable to locate RPi-ap directory"
echo "No RPi-ap Files Removed"
fi

}
#
########################
###    ASK_SUDOERS   ###
########################
ask_Sudoers () {
echo "Setting sudoers..."

if [[ -f /etc/sudoers.d/010_RPi-ap ]]
then echo "Removing sudoers file"
rm /etc/sudoers.d/010_RPi-ap
  if [[ -f /etc/sudoers.d/010_RPi-ap ]]
  then echo -e "unable to remove sudoers file\n"
  else echo -e "sudoers file removed\n"
  fi
else echo -e "sudoers file doesn't exist\n"
fi

}
#
########################
###    ASK_HOSTAPD   ###
########################
ask_Hostapd () {
echo "Setting hostapd..."

if [[ -f $bk/hostapd.conf ]]
then mv $bk/hostapd.conf /etc/hostapd/
echo -e "hostapd.conf restored from backup\n"
else apt purge hostapd -y -qq > /dev/null

  if [[ -d /etc/hostapd ]]
  then rm -r /etc/hostapd
  fi

echo -e "Uninstalled hostapd\n"
fi

}
#
########################
###    ASK_DNSMASQ   ###
########################
ask_Dnsmasq () {
echo "Setting dnsmasq..."

if [[ -f $ff ]]
then
cp $ff $f
chown root:root $f
chmod u+rw,g+r,o+r $f
echo -e "dnsmasq.conf restored from backup\n"
else
echo "missing dnsmasq.conf for sta-ap"
echo "loading default"
cp $stadir/$req/default/dnsmasq.conf $f
chown root:root $f
chmod u+rw,g+r,o+r $f
echo -e "default dnsmasq.conf loaded\n"
fi

}
#
#######################
###    ASK_DHCPCD   ###
#######################
ask_Dhcpcd () {
echo -e "\nSetting dhcpcd..."

if [[ -f $gg ]]
then
cp $gg $g
chown root:netdev $g
chmod u+rw,g+rw,o+r $g
echo -e "dhcpcd.conf restored from backup\n"
else
echo "missing dhcpcd.conf for sta-ap"
echo "loading default"
cp $stadir/$req/default/dhcpcd.conf $g
chown root:netdev $g
chmod u+rw,g+rw,o+r $g
echo -e "default dhcpcd.conf loaded\n"
fi

}
#
#######################
###   ASK_SERVICE   ###
#######################
ask_Service () {
echo -e "\nRemoving system service configuration..."

if [[ -f /etc/systemd/system/RPi-ap-check.service ]]
then systemctl disable RPi-ap-check.service
s5
s5

  if [[ ! -f /etc/systemd/system/RPi-ap-check.service ]]
  then echo "RPi-ap service removed"
  else echo "Unable to remove service.  Try manually with sudo systemctl disable RPi-ap-check.service"
  fi

else echo "unable to locate RPi-ap-check.service"
fi

}
#
#####################
###   ASK_WPA   ###
#####################
ask_Wpa () {
echo -e "\nSetting wpa_supplicant..."

if [[ -f $dd ]]
then echo "Restoring wpa_supplicant"
mv $dd $d
echo "wpa_supplicant.conf restored"
else echo "Unable to locate backup for wpa_supplicant"
read -r -p "Do you want to load a default wpa file? Wifi may not work without it.  [Y/n]" ask_wpa_input
case $ask_wpa_input in
[yY][eE][sS]|[yY])
echo "Loading default wpa_supplicant"

  if [[ -f $stadir/$req/default.wpa_supplicant.conf ]]
  then cp $stadir/$req/default.wpa_supplicant.conf $d
  else echo "unable to locate default wpa_supplicant"
  echo "no change made"
  fi

;;
[nN][oO]|[nN])
echo "No change made to $d"
;;
*)
echo "Must enter (Y or N)"
s
exit 0
;;
esac
fi

}
#
###########################
###   UNINSTALL_UNZIP   ###
###########################
ask_Unzip () {
echo -e "\nUninstalling unzip...\n"

if type unzip &>/dev/null
then apt purge unzip -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s

  if type unzip &>/dev/null
  then echo "error removing unzip. Try removing manually with sudo apt purge unzip"
  else echo -e "Uninstalled unzip\n"
  fi

else
echo -e "Unable to determine if the unzip package is installed or not, but will continue processing.\n"
fi

}
#
#############################
###     RESTORE_APACHE    ###
#############################
restore_apache () {

if type apache2 &>/dev/null
then echo "checking backups"

  if [[ -f $ee ]]
  then
  mv $ee $e
  chown www-data:www-data $e
  chmod 644 $e
  echo "index.html restored from backup"
  else
  echo "no backup for index.html"
  echo "no change made"
  fi

  if [[ -f $bb ]]
  then
  mv $bb $b
  echo "login.php restored from backup"
  chown www-data:www-data $b
  echo "no permission changes made"
  else
  echo "no backup for login.php"
  rm $b
  echo "login.php removed"
  fi

else
echo "Unable to determine if apache2 is installed"
fi

}
#
#############################
###    UNINSTALL_APACHE   ###
#############################
uninstall_apache () {

if type apache2 &>/dev/null
then apt purge apache2 -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s5

  if type apache2 &>/dev/null
  then echo "ERROR: unable to confirm removal of apache2. Try removing manually with sudo apt purge apache2"
  else echo "Uninstalled apache2"
  fi

else
echo "Unable to determine if the apache2 package is installed or not, but will continue processing."
fi

if [[ -d /etc/apache2 ]]
then echo -e "\nRemoving remaining traces of apache2..."
rm -r /etc/apache2/
else :
fi

if [[ -d /var/www ]]
then rm -r /var/www
else :
fi

if dpkg -l | grep -qw $k
then apt purge $k -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s

  if dpkg -l | grep -qw $k
  then echo "There was an issue removing $k.  Try removing manually with sudo apt purge $k"
  else echo "Uninstalled $k"
  fi

else "Unable to verify that the package $k is installed or not, but will continue processing."
fi

if dpkg -l | grep -qw $h
then apt purge $h -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s

  if dpkg -l | grep -qw $h
  then echo "There was an issue removing $h.  Try removing manually with sudo apt purge $h"
  else echo "Uninstalled $h"
  fi

else
  if dpkg -l | grep -qw $hh
  then apt purge $hh -y -qq > /dev/null
  apt autoremove -y -qq > /dev/null
  s

    if dpkg -l | grep -qw $hh
    then echo "There was an issue removing $hh.  Try removing manually with sudo apt purge $hh"
    else echo "Uninstalled $hh"
    fi

  else
    if dpkg -l | grep -qw $hhh
    then apt purge $hhh -y -qq > /dev/null
    apt autoremove -y -qq > /dev/null
    s

      if dpkg -l | grep -qw $hhh
      then echo "There was an issue removing $hhh.  Try removing manually with sudo apt purge $hhh"
      else echo "Uninstalled $hhh"
      fi

    else echo "Unable to verify that the package $h, $hh, or $hhh is installed or not, but will continue processing."
    fi
  fi
fi

if dpkg -l | grep -qw $j
then apt purge $j -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s

  if dpkg -l | grep -qw $j
  then echo "There was an issue removing $j.  Try removing manually with sudo apt purge $j"
  else echo "Uninstalled $j"
  fi

else echo "Unable to verify that the package $j is installed or not, but will continue processing."
fi

}
#
######################
###   ASK_APACHE   ###
######################
ask_Apache () {
while true
do
echo "It is okay to leave apache installed if you are not going to have a forward facing server."
read -r -p "Do you want to [Y]uninstall or [N]restore Apache Web Server? Type [Y or N] : " ask_apache_input
case $ask_apache_input in
[yY])
echo -e "\nBegin Uninstalling Apache...\n"
uninstall_apache
s
break
;;
[nN])
echo "Restoring Apache"
restore_apache
s
break
;;
*)
echo "Must enter (y or n)"
s
exit 0
;;
esac
done
}
#
#####################
###   ASK_START   ###
#####################
ask_Start () {
while true
do
read -r -p "Do You Want To Uninstall RPi-ap? [Y/n]" ask_start_input
case $ask_start_input in
[yY][eE][sS]|[yY])
echo -e "\nBegin Uninstalling RPi-ap\n"
s
ask_Apache
s
ask_Unzip
s
ask_Wpa
s
ask_Service
s
ask_Dhcpcd
s
ask_Dnsmasq
s
ask_Hostapd
s
ask_Sudoers
s
echo "Restarting network..."

if type hostapd &>/dev/null
then systemctl stop hostapd
systemctl disable hostapd
systemctl mask hostapd
else :
fi

systemctl restart dhcpcd
s
ask_RPi-ap
s
echo -e "\nRPi-ap uninstall complete\n"
echo -e "\nMay need to reboot in order to complete the network reconfiguration\n"
break
;;
[nN][oO]|[nN])
echo "Cancelled"
break
;;
*)
echo "Must enter (Y/n)"
s
exit 1
;;
esac
done
}
#
############################
#      Initial Checks      #
############################
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
#
#############################################
#              Begin Script                 #
#############################################
ask_Start

echo "REBOOTING"
reboot
exit 0
#########################################
