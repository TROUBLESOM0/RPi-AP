#!/bin/bash
echo "Installing wget"
apt install wget -y -qq > /dev/null
sleep 1

if type wget &>/dev/null
then echo -e "Installed wget\n"
return
else
echo -e "${Error}ERROR${Off} wget installation failed. Try installing manually with \"sudo apt install wget\" and run again"
exit 1
fi
