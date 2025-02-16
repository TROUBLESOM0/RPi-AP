#!/bin/bash
#
#
echo "This will remove all associated files and settings related to Lilypin"
echo "And will try to revert back to the original files and settings"
echo ""
echo "If an issue occurs, script should provide information on the issue and"
echo "query whether you want to continue or not."
echo "----------------------------------------------------------------------"
echo "FILE/FOLDER REMOVAL :"
echo "   - lilypin/ in /usr/local/etc/ "
echo "   - lilypin-check.service in /etc/systemd/system/ "
echo "   - login.php, login.data, index.html in /var/www/html/ "
echo "   - hostapd.conf in /etc/ "
echo ""
echo "FILE/FOLDER RESTORE :"
echo "   - login.php, index.html if existed previosly "
echo "   - dnsmasq.conf in /etc/ "
echo "   - dhcpcd.conf in /etc/ "
echo "   - hostapd.conf in /etc/hostapd/ , only if it existed previously "
echo ""
echo "----------------------------------------------------------------------"
echo "This script will query whether user would like to remove the dependancies"
echo "  i.e. apache2, unzip, hostapd, libapache2-mod-php"
echo ""
echo ""
#
#
### VARIABLES ###
#################
rootdir=/usr/local/etc/lilypin
stadir=/usr/local/etc/lilypin/sta-ap
req=required
whtml=$stadir/web/index.html
wlogin=$stadir/web/login.php
ap=/var/www/html
service=lilypin-check.service
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
#
### Variables for Restoring ###
bk=$dir/pre-sys-bkup
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
#######################
###   ASK_SERVICE   ###
#######################
ask_Service () {
if [[ -f /etc/systemd/system/lilypin-check.service ]]
then systemctl disable lilypin-check.service
  if [[ -f /etc/systemd/system/lilypin-check.service ]]
  then echo "Lilypin service removed"
  else echo "Unable to remove service.  Try manually with sudo systemctl disable lilypin-check.service"
  fi
else echo "unable to locat lilypin-check.service"
fi
#
#####################
###   ASK_WPA   ###
#####################
ask_Wpa () {
if [[ -f $dd ]]
then echo "Restoring wpa_supplicant"
mv $dd $d
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
break
;;
[nN][oO]|[nN])
echo "No change made to $d"
break
;;
*)
echo "Must enter (Y or N)"
s
exit 0
;;
esac
echo "WPA_Supplicant restored"
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
  echo "index.html restored"
  else echo "no backup for index.html"
  echo "no change made"
  fi

  if [[ -f $bb ]]
  then
  mv $bb $b
  echo "login.php restored"
  chown www-data:www-data $b
  echo "no permission changes made"
  else echo "no backup for login.php"
  echo "no change made"
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
if dpkg -l | grep -qw libapache2-mod-php
then apt purge libapache2-mod-php -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s
  if dpkg -l | grep -qw libapache2-mod-php
  then echo "There was an issue removing libapache2-mod-php.  Try removing manually with sudo apt purge libapache2-mod-php"
  else echo "libapache2-mod-php uninstalled"
  fi
else "Unable to verify that libapache2-mod-php is installed."
fi

if type apache2 &>/dev/null
then apt purge apache2 -y -qq > /dev/null
s
  if [[ -d /var/www ]]
  rm -r /var/www
  else :
  fi
apt autoremove -y -qq > /dev/null
  if type apache2 &>/dev/null
  then echo "error removing apache2. Try removing manually with sudo apt purge apache2"
  else echo "apache removed"
  fi
else
echo "Unable to determine if apache2 is installed."
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
read -r -p "Do you want to [1]uninstall or [2]restore Apache Web Server? Type [1 or 2] : " ask_apache_input
case $ask_apache_input in
[1])
echo "Begin Uninstalling Apache"
uninstall_apache
s
break
;;
[2])
echo "Restoring Apache"
restore_apache
s
break
;;
*)
echo "Must enter (1 or 2)"
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
read -r -p "Do You Want To Uninstall Lilypin? [Y/n]" ask_start_input
case $ask_start_input in
[yY][eE][sS]|[yY])
echo "Begin Uninstalling Lilypin"
s
ask_Apache
s
ask_Wpa
s
ask_Service
s
break
;;
[nN][oO]|[nN]
echo "Cancelled"
break
;;
*)
echo "Must enter (Y/n)"
s
exit 0
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

echo "ENDING"
#########################################
