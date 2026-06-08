#!/bin/bash
# installs apache-php
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
echo "apache php module installation failed. Try installing manually with sudo apt install libapache2-mod-php$pV"
exit 1
fi

# load apache php module
dpkg -l | grep -qw libapache2-mod-php$pV
if [ $? -eq 0 ]
then echo -e "\nLoading apache php module"
ask_Loadmod-php


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

echo -e "\nInitial Checks Complete\n"
else
echo -e "${Error}ERROR${Off} libapache2-mod-php$pV was not installed\n"
fi
