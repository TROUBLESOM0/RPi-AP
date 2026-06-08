#!/bin/bash
# install apache2
echo "Installing apache2"
sleep 1
apt install apache2 -y -qq > /dev/null
sleep 1

if type apache2 &>/dev/null
then :
else
echo -e "${Error}ERROR${Off} Apache2 installation failed. Try installing manually with sudo apt install apache2"
exit 1
fi
