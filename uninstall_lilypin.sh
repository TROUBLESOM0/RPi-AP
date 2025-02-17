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
h=libapache2-mod-php7.4
j=apache2-doc
k=apache2-bin
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
########################
###    ASK_LILYPIN   ###
########################
ask_Lilypin () {

if [[ -d $rootdir ]]
then rm -r $rootdir
echo "Lilypin files removed"
else echo "Unable to locat Lilypin directory"
echo "No Lilypin Files Removed"
fi

}
#
########################
###    ASK_HOSTAPD   ###
########################
ask_Hostapd () {

if [[ -f $bk/hostapd.conf ]]
then mv $bk/hostapd.conf /etc/hostapd/
echo "hostapd.conf restored from backup"
else apt purge hostapd -y -qq > /dev/null
  
  if [[ -d /etc/hostapd ]]
  then rm -r /etc/hostapd
  fi

echo "Uninstalled hostapd"
fi

}
#
########################
###    ASK_DNSMASQ   ###
########################
ask_Dnsmasq () {

if [[ -f $ff ]]
then :
else echo "missing dnsmasq.conf for sta-ap"
echo "no change made"
fi

cp $ff $f
chown root:root $f
chmod u+rw,g+r,o+r $f
echo "dnsmasq.conf restored from backup"
}
#
#######################
###    ASK_DHCPCD   ###
#######################
ask_Dhcpcd () {

if [[ -f $gg ]]
then :
else echo "missing dhcpcd.conf for sta-ap"
echo "no change made"
fi

cp $gg $g
chown root:netdev $g
chmod u+rw,g+rw,o+r $g
echo "dhcpcd.conf restored from backup"
}
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

}
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
echo "WPA_Supplicant restored from backup"
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
  else echo "no backup for index.html"
  echo "no change made"
  fi

  if [[ -f $bb ]]
  then
  mv $bb $b
  echo "login.php restored from backup"
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

if type apache2 &>/dev/null
then apt purge apache2 -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s

  if type apache2 &>/dev/null
  then echo "error removing apache2. Try removing manually with sudo apt purge apache2"
  else echo "Uninstalled apache2"
  fi

else
echo "Unable to determine if the apache2 package is installed or not, but will continue processing."
fi

if [[ -d /etc/apache2 ]]
then echo "Removing leftover apache directory"
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

else "Unable to verify that the package $h is installed or not, but will continue processing."
fi

if dpkg -l | grep -qw $j
then apt purge $j -y -qq > /dev/null
apt autoremove -y -qq > /dev/null
s
  
  if dpkg -l | grep -qw $j
  then echo "There was an issue removing $j.  Try removing manually with sudo apt purge $j"
  else echo "Uninstalled $j"
  fi

else "Unable to verify that the package $j is installed or not, but will continue processing."
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
ask_Dhcpcd
s
ask_Dnsmasq
s
ask_Hostapd
s
echo "Restarting Network"
systemctl stop hostapd
systemctl disable hostapd
systemctl mask hostapd
systemctl restart dhcpcd
s
ask_Lilypin
s
echo "Lilypin uninstall complete"
echo "May need to reboot in order to complete the network reconfiguration"
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

echo "ENDING"
exit 0
#########################################
