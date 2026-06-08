#!/bin/bash
# installs hostapd
echo "Installing hostapd"
apt install hostapd -y -qq > /dev/null
sleep 1

if type hostapd &>/dev/null
then echo -e "Installed hostapd\n"
return
else
echo -e "${Error}ERROR${Off} hostapd installation failed. Try installing manually with \"sudo apt install hostapd\" and run again"
exit 1
fi
