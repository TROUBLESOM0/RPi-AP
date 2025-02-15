#!/bin/bash
#
#
echo "This will install the Lilypin Access Point"
echo "for connecting to a WiFi Access Point"
echo "via a web browser interface."
echo "This script will perform the following actions:"
echo "1. Perform initial checks to determine required system programs are installed or present"
echo "2. Download a selection of .bash scripts and save in the location:"
echo -e "  \033[1;33m/usr/local/etc/lilypin\e[0m"
echo "3. Setup the lilypin-check.service into /etc/systemd/system/ folder to run on boot"
echo "        - this creates a local AP for configuring a wireless connection if none is present"
#
#
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
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
gitLink="https://github.com/TROUBLESOM0/LilyPin/archive/refs/heads/main.zip"
service=lilypin-check.service

############################
###   ASK_INSTALLUNZIP   ###
############################
ask_Installunzip () {
echo "Installing unzip"
apt install unzip -y -qq > /dev/null
sleep 1

if type unzip &>/dev/null
then :
else
echo "unzip installation failed. Try installing manually with sudo apt install unzip"
exit 1
fi

}
# 
############################
###   ASK_INSTALLHOSTAPD   ###
############################
ask_Installhostapd () {
echo "Installing hostapd"
apt install hostapd -y -qq > /dev/null
sleep 1

if type hostapd &>/dev/null
then :
else
echo "hostapd installation failed. Try installing manually with sudo apt install hostapd"
exit 1
fi

}
# 
##############################
###   ASK_INSTALLAPACHE2   ###
##############################
ask_Installapache2 () {
echo "Installing apache2"
sleep 1
apt install apache2 -y -qq > /dev/null
sleep 1

if type apache2 &>/dev/null
then :
else
echo "apache2 installation failed. Try installing manually with sudo apt install apache2"
exit 1
fi

}
#
##############################
###   ASK_INSTALLMOD-PHP   ###
##############################
ask_Installmod-php () {
echo "Installing libapache2-mod-php"
sleep 1
apt install libapache2-mod-php -y -qq > /dev/null
sleep 1
dpkg -l | grep -qw libapache2-mod-php

if [ $? -eq 0 ] 
then :
else
echo "apache php module installation failed. Try installing manually with sudo apt install libapache2-mod-php"
exit 1
fi

}
#
###########################
###   ASK_LOADMOD-PHP   ###   THIS ISN'T WORKING RIGHT
###########################
ask_Loadmod-php () {
PHP_VERSION=$(php -v | head -n 1 | awk '{print $2}')
echo "Identifying the module name based on the PHP version"
MODULE_NAME="php${PHP_VERSION}"
echo "Checking if the module exists"

if apache2ctl -M | grep -q "${MODULE_NAME}_module"
then echo "PHP module ${MODULE_NAME} is already enabled."
else
echo "Enabling ${MODULE_NAME} module for Apache2..."    
a2enmod "${MODULE_NAME}"    
echo "Restarting Apache..."
systemctl restart apache2
sleep 1
echo "${MODULE_NAME} module has been enabled and Apache2 has been restarted."
fi

}
#
##################
###   ASK_DL   ###
##################
ask_DL () {
echo "Downloading files..."
wget -q $gitLink -P /usr/local/etc/

if [[ -f /usr/local/etc/main.zip ]]
then :
else echo "Download failed"
exit 1
fi

unzip -qq -o /usr/local/etc/main.zip -d /usr/local/etc/
mv /usr/local/etc/LilyPin-main/ /usr/local/etc/lilypin
rm /usr/local/etc/main.zip
#rm $rootdir/Lilypin-install.sh

if [[ -f $stadir/c_start.sh ]]
then :
else echo "c_start.sh missing"
exit 1
fi

if [[ -f $stadir/check-net.sh ]]
then :
else echo "check-net.sh missing"
exit 1
fi

if [[ -f $stadir/sta-ap.start ]]
then :
else echo "sta-ap.start missing"
exit 1
fi

if [[ -f $stadir/sta-ap.stop ]]
then :
else echo "sta-ap.stop missing"
exit 1
fi

chmod u+x,g+x $stadir/c_start.sh
chmod u+x,g+x $stadir/check-net.sh
chmod u+x,g+x $stadir/sta-ap.start
chmod u+x,g+x $stadir/sta-ap.stop

}
#
##############################
###   ASK_INSTALL-SERVICE   ###
##############################
ask_Install-service () {
# check service file exists
if [[ ! -f $stadir/$req/$service ]]
then echo -e "${Error}ERROR${Off} $service is missing!"
exit 1
else
chown root:root $stadir/$req/$service
chmod u+rwx,g+rx,o+r $stadir/$req/$service
sleep 2
ln -s $stadir/$req/$service /etc/systemd/system/$service
sleep 1
echo "enabling service..."
systemctl enable $service
# check for errors on service
echo "checking for errors..."
  if systemctl is-enabled "$service" &>/dev/null
  then echo "service is enabled"
  else
  echo "There was an issue configuring the service '$service'!"
  echo "Run Uninstall script"
  echo "Then try re-installing"
  exit 1
  fi
fi
}
#
############################
#      Initial Checks      #
############################
# check if unzip is installed
if type unzip &>/dev/null
then : # continues script
else
echo "ERROR unzip is not installed"
ask_Installunzip
echo "unzip install complete"
fi

# check if hostapd is installed
if type hostapd &>/dev/null
then : # continues script
else
echo "ERROR hostapd is not installed"
ask_Installhostapd
echo "hostapd install complete"
fi

# check if apache2 is installed
if type apache2 &>/dev/null
then :
else
echo "ERROR: apache2 is not installed"
ask_Installapache2
fi

# check if apache php module is installed
dpkg -l | grep -qw libapache2-mod-php
if [ $? -eq 0 ] 
then :
else
ask_Installmod-php
fi
ask_Loadmod-php
#
#############################################
#              Begin Script                 #
#############################################
echo "Starting Installation..."
echo "Checking for previous installation"

if test -d $rootdir
then rm -r $rootdir
echo "removed previous installation"
else echo "No previous installation found. Start initial install"
fi

echo "Downloading LilyPin..."
ask_DL
echo "Download Complete"
echo "Configuring service in systemd..."
ask_Install-service
echo "Should be ready for Reboot now"
echo "REBOOTING"
#reboot now
exit 0
