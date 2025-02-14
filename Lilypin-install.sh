#!/bin/bash
#
#
echo "This will install the Lilypin Access Point"
echo "for connecting to a WiFi Access Point"
echo "via a web browser interface."
#
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
#
#
# variables
rootdir=/usr/local/etc/lilypin
stadir=/usr/local/etc/lilypin/sta-ap
req=required
whtml=$stadir/web/index.html
wlogin=$stadir/web/login.php
ap=/var/www/html

##############################
###   ASK_INSTALLAPACHE2   ###
##############################
ask_Installapache2 () {
echo "Installing apache2"
sleep 1
sudo apt install apache2 -y -qq > /dev/null
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
sudo apt install libapache2-mod-php -y -qq > /dev/null
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
###   ASK_LOADMOD-PHP   ###
###########################
ask_Loadmod-php () {
PHP_VERSION=$(php -v | head -n 1 | awk '{print $2}')
# Identify the module name based on the PHP version
MODULE_NAME="php${PHP_VERSION}"
# Check if the module exists
if apache2ctl -M | grep -q "${MODULE_NAME}_module"
then echo "PHP module ${MODULE_NAME} is already enabled."
else
echo "Enabling ${MODULE_NAME} module for Apache2..."    
# Enable the PHP module for Apache2
sudo a2enmod "${MODULE_NAME}"    
# Restart Apache to apply the changes
sudo systemctl restart apache2
echo "${MODULE_NAME} module has been enabled and Apache2 has been restarted."
fi
}
#
##################
###   ASK_DL   ###
##################
echo "Downloading files..."
sudo wget https://github.com/TROUBLESOM0/LilyPin/archive/refs/heads/main.zip /usr/local/etc/
if [[ -f main.zip ]]
then :
else echo "Download failed"
exit 1
fi
unzip -qq -o /usr/local/etc/main.zip
sudo mv /usr/local/etc/LilyPin-main/ /usr/local/etc/lilypin
sudo rm /usr/local/etc/main.zip
sudo rm $rootdir/Lilypin-install.sh
sudo bash $stadir/sta-ap.start

############################
#      Initial Checks      #
############################
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
#############################################
#              Begin Script                 #
#############################################
echo "Starting Installation..."
echo "Checking for previous installation"
if test -d $rootdir
then rm -r $rootdir
echo "removed previous installation"
else echo "start initial install"
ask_DL
echo "Installation Complete"
exit 0
