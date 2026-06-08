#!/bin/bash
# check if unzip is installed
if type unzip &>/dev/null
then echo -e "\nunzip already installed\n"
: # continues script
else
echo -e "\nUnzip is not installed"
# installs unzip
echo "Installing unzip"
apt install unzip -y -qq > /dev/null
sleep 1

  if type unzip &>/dev/null
  then echo -e "Installed unzip\n"
  :
  else
  echo -e "${Error}ERROR${Off} unzip installation failed. Try installing manually with \"sudo apt install unzip\" and run again"
  exit 1
  fi

fi
