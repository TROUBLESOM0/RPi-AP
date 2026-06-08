#!/bin/bash
# check if apache-php is installed
dpkg -l | grep -qw libapache2-mod-php | grep -E "7.4|7.3|7.2"
if [ $? -eq 0 ] 
then echo -e "\nphp-module already installed\n"
:
else
echo -e "\nLibapache2-mod-php is not installed"
source $installapachephp || exit 1
echo -e "libapache2-mod-php$pV install complete\n"
fi
