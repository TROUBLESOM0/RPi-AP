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
