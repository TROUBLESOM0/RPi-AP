#!/bin/bash
# check if wget is installed
if type wget &>/dev/null
then echo -e "\nwget already installed\n"
: # continues script
else
echo -e "\nwget is not installed"
echo "Installing wget"
apt install wget -y -qq > /dev/null
sleep 1

  if type wget &>/dev/null
  then echo -e "Installed wget\n"
  :
  else
  echo -e "${Error}ERROR${Off} wget installation failed. Try installing manually with \"sudo apt install wget\" and run again"
  exit 1
  fi
  
fi
