#!/bin/bash
#
# ap-install.sh v.1
#
echo "This will install a Local Access Point"
echo "for connecting to a WiFi Access Point"
echo "via a web browser interface."
echo "This script will perform the following actions:"
echo "1. Perform initial checks to determine required system programs are installed or present"
echo "2. Download a selection of .bash scripts and save in the location:"
echo -e "  \033[1;33m/usr/local/etc/RPi-ap\e[0m"
echo "3. Setup the RPi-ap-check.service into /etc/systemd/system/ folder to run on boot"
echo -e "        - this creates a local AP for configuring a wireless connection if none is present\n"
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
rootdir=/usr/local/etc/RPi-ap
stadir=/usr/local/etc/RPi-ap/sta-ap
req=required
whtml=$stadir/web/index.html
wlogin=$stadir/web/login.php
ap=/var/www/html
gitLink="https://github.com/TROUBLESOM0/RPi-AP/archive/refs/heads/main.zip"
service=RPi-ap-check.service
_break="---------------"

############################
###   ASK_INSTALLUNZIP   ###
############################
ask_Installunzip () {
echo "Installing unzip"
apt install unzip -y -qq > /dev/null
sleep 1

if type unzip &>/dev/null
then echo -e "Installed unzip\n"
return
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
then echo -e "Installed hostapd\n"
return
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
apt-cache show libapache2-mod-php7.4 2>/dev/null | grep Version 2>/dev/null > /dev/null

if [ $? -eq 0 ]
then
pV=7.4
else
apt-cache show libapache2-mod-php7.3 2>/dev/null | grep Version 2>/dev/null > /dev/null
  if [ $? -eq 0 ]
  then
  pV=7.3
  else
  apt-cache show libapache2-mod-php7.2 2>/dev/null | grep Version 2>/dev/null > /dev/null
    if [ $? -eq 0 ]
    then
    pV=7.2
    else
    echo -e "\nERROR: No Available Package for libapache2-mod-php"
    echo -e "Must be 7.4, 7.3, or 7.2\n"
    echo -e "Exiting.\n"
    exit 1
    fi 
  fi
fi

apt install libapache2-mod-php$pV -y -qq > /dev/null
sleep 1
dpkg -l | grep -qw libapache2-mod-php$pV

if [ $? -eq 0 ] 
then :
else
echo "apache php module installation failed. Try installing manually with sudo apt install libapache2-mod-php7.4"
exit 1
fi

}
#
###########################
###   ASK_LOADMOD-PHP   ###
###########################
ask_Loadmod-php () {
php_ver=$(php -v | head -n 1 | awk '{print $2}' | cut -d '.' -f1-2)
echo "Identifying the module name based on the PHP version"
module_name="php${php_ver}"
echo "Checking if the module exists"

if [[ -f /etc/apache2/mods-available/$module_name.conf ]]
then :
else echo -e "\n***ERROR: PHP module missing from apache."
exit 1
fi

if [[ -f /etc/apache2/mods-enabled/$module_name.conf ]]
then echo -e "php module enabled in apache\n"
else echo "attempting to enable module in apache"
a2enmod $module_name
sleep 3
systemctl restart apache2
sleep 3
  if [[ -f /etc/apache2/mods-enabled/$module_name.conf ]]
  then echo -e "php module enabled in apache\n"
  else echo -e "\n***ERROR: Unable to enable php module in apache.\n"
  exit 1
  fi
fi

}
#
###############################
###   ASK_INSTALL-SERVICE   ###
###############################
ask_Install-service () {
# check service file exists

if [[ -f /etc/systemd/system/$service ]]
then echo "removing existing service"
systemctl disable $service
else :
fi

if [[ ! -f $stadir/$req/$service ]]
then echo -e "${Error}ERROR${Off} $service is missing!\n"
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
  then echo -e "service is enabled\n"
  else
  echo "There was an issue configuring the service '$service'!"
  echo "Run Uninstall script"
  echo -e "Then try re-installing\n"
  exit 1
  fi
fi

}
#
###################
###   ASK_LOG   ###
###################
ask_Log () {
#logs

if [[ ! -f /usr/local/etc/RPi-ap/sta-ap/log ]]
then
echo -e "Creating log file...\n"
touch /usr/local/etc/RPi-ap/sta-ap/log
echo "$(date)---INSTALLATION FOR RPI-AP---" >> /usr/local/etc/RPi-ap/sta-ap/log
else echo "" >> /usr/local/etc/RPi-ap/sta-ap/log
echo "$(date)---RE-INSTALLING RPI-AP---" >> /usr/local/etc/RPi-ap/sta-ap/log
fi

exec > >(tee -a /usr/local/etc/RPi-ap/sta-ap/log) 2>&1
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
else echo -e "\n***ERROR:  Download failed. Run installation again."
exit 1
fi

unzip -qq -o /usr/local/etc/main.zip -d /usr/local/etc/

if [[ -d /usr/local/etc/RPi-AP-main ]]
then :
else echo -e "\n***ERROR: There was an issue extracting the downloaded .zip file in /usr/local/etc/."
echo "Run installation again."
exit 1
fi

mv /usr/local/etc/RPi-AP-main/ /usr/local/etc/RPi-ap
rm /usr/local/etc/main.zip

if [[ -d $rootdir ]]
then echo "Download complete"
echo "Verifying presence of files..."
fi

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

if [[ -f $rootdir/uninstall-ap.sh ]]
then :
else echo "uninstall-ap.sh missing"
exit 1
fi

# add sudo file to /etc/sudoers.d/
if [[ ! -f /etc/sudoers.d/010_RPi-ap ]]
then echo "Adding permission to sudoers.d"
cp $stadir/$req/010_RPi-ap /etc/sudoers.d/010_RPi-ap
chmod 440 /etc/sudoers.d/010_RPi-ap
  if [[ -f /etc/sudoers.d/010_RPi-ap ]]
  then echo "sudoers file added"
  else echo "***ERROR adding sudoers file***"
  fi
else echo "sudoers file already exists"
echo "updating..."
rm /etc/sudoers.d/010_RPi-ap
cp $stadir/$req/010_RPi-ap /etc/sudoers.d/010_RPi-ap
chmod 440 /etc/sudoers.d/010_RPi-ap
  if [[ -f /etc/sudoers.d/010_RPi-ap ]]
  then echo "sudoers file updated"
  else echo "***ERROR updating sudoers file***"
  fi
fi

#########################
# Configure Permissions #
#########################
chmod u+x,g+x $stadir/c_start.sh
chmod u+x,g+x $stadir/check-net.sh
chmod u+x,g+x $stadir/sta-ap.start
chmod u+x,g+x $stadir/sta-ap.stop
chown root:www-data $stadir/web/run-check.sh
chmod u+rw,g+rx,o+r $stadir/web/run-check.sh
chmod u+rwx,g+rx,o+r $rootdir/uninstall-ap.sh

}
#
############################
#      Initial Checks      #
############################
echo "Starting initial checks..."
# update apt
apt update -qq 2>/dev/null >/dev/null

# check if unzip is installed

echo $_break

if type unzip &>/dev/null
then echo -e "\nunzip already installed\n"
: # continues script
else
echo -e "\nUnzip is not installed"
ask_Installunzip
fi

echo $_break

# check if hostapd is installed
if type hostapd &>/dev/null
then echo -e "\nhostapd already installed\n"
: # continues script
else
echo -e "\nHostapd is not installed"
ask_Installhostapd
fi

echo $_break

# check if apache2 is installed
if type apache2 &>/dev/null
then echo -e "\napache already installed\n"
:
else
echo -e "\nApache is not installed"
ask_Installapache2
echo -e "apache2 install complete\n"
fi

echo $_break

# check if apache php module is installed
dpkg -l | grep -qw libapache2-mod-php | grep -E "7.4|7.3|7.2"
if [ $? -eq 0 ] 
then echo -e "\nphp-module already installed\n"
:
else
echo -e "\nLibapache2-mod-php is not installed"
ask_Installmod-php
echo -e "libapache2-mod-php install complete\n"
fi

echo $_break

# load apache php module
dpkg -l | grep -qw libapache2-mod-php | grep -E "7.4|7.3|7.2"
if [ $? -eq 0 ]
then echo -e "\nLoading apache php module"
ask_Loadmod-php
echo -e "\nInitial Checks Complete\n"
else
echo -e "\nERROR: libapache2-mod-php was not installed\n"
fi

#
#############################################
#              Begin Script                 #
#############################################
echo "Starting Installation..."
echo "Checking for previous installation"

if test -d $rootdir
then rm -r $rootdir
echo -e "removed previous installation\n"
else echo -e "No previous installation found. Start initial install\n"
fi

echo "Downloading RPI-AP..."
ask_DL
echo ""
ask_Log
echo -e "\nConfiguring service in systemd..."
ask_Install-service
echo -e "\nREBOOTING\n"
reboot
exit 0
