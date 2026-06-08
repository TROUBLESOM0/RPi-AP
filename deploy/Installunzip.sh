#!/bin/bash
# installs unzip
echo "Installing unzip"
apt install unzip -y -qq > /dev/null
sleep 1

if type unzip &>/dev/null
then echo -e "Installed unzip\n"
return
else
echo -e "${Error}ERROR${Off} unzip installation failed. Try installing manually with \"sudo apt install unzip\" and run again"
exit 1
fi
