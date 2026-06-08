#!/bin/bash
# check if apache2 is installed
if type apache2 &>/dev/null
then echo -e "\napache already installed\n"
:
else
echo -e "\nApache is not installed"
source $installapache || exit 1
echo -e "apache2 install complete\n"
fi
