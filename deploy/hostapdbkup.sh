#!/bin/bash
DATE=$(date +%Y%m%d)
USER=${SUDO_USER:-$USER}
BKHOSTAPD="/home/$USER/bkuphost/hostapd_bkup"

if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi

if [ -d /etc/hostapd ]
then echo "hostapd folder exists"

  if [ ! -d $BKHOSTAPD ]
  then echo "bkup doesn't exist"
  sudo -u $USER mkdir -p $BKHOSTAPD/

    if [ -d $BKHOSTAPD ]
    then echo "successfully created bkuphost folder"
    echo "copying hostapd"
    cp -a /etc/hostapd $BKHOSTAPD/
    echo "ran the copy command"

      if [ ! -d $BKHOSTAPD/hostapd ]
      then echo "Failed to copy hostapd folder"
      exit 1
      else echo "Successfully copied hostapd folder"
      fi

    else echo "faild to makd backeup folder"
    exit 1
    fi

  else echo "bkup folder already exists"

    if [ -d $BKHOSTAPD* ]
    then echo "hostapd alredy been backed up"
    echo "making new bakup  hostapd${DATE}"
    sudo -u $USER mkdir -p $BKHOSTAPD$DATE
    cp -a /etc/hostapd $BKHOSTAPD$DATE/
    else echo "making new bkup"
    cp -a /etc/hostapd $BKHOSTAPD$DATE/
    fi

  fi

else echo "hostapd appears not be installed"
fi
