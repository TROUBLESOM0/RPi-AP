#!/bin/bash
# check if hostapd is installed
if type hostapd &>/dev/null
then echo -e "\nHostapd already installed\n"

  if [[ -f $hostapdbkup_scr ]]
  then source $hostapdbkup_scr
  else echo -e "${Error}ERROR${Off} hostapdbkup.sh missing.  Unable to backup hostapd before making changes"
  exit 1
  fi
  
else
echo -e "\nHostapd is not installed"
source $installhostapd || exit 1
fi
