#!/bin/bash
Error='\033[1;31m'   # Bold red
Off='\033[0m'
DATE=$(date +%Y%m%d_%H%M)
USER=${SUDO_USER:-$USER}
SOURCE_FOLDER="/etc/hostapd"
SOURCE_NAME="${SOURCE_FOLDER##*/}_bkup"
BACKUP_FOLDER=$bkupdir/$SOURCE_NAME

echo "backup folder is : $BACKUP_FOLDER"
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi

echo "---------------------------------"
echo "    Backing Up $SOURCE_FOLDER    "
echo -e "-------------------------------\n"

if [ -d $SOURCE_FOLDER ]
then echo "Found $SOURCE_FOLDER folder"

  if [ ! -d $BACKUP_FOLDER ]
  then echo "Creating backup folder in $BACKUP_FOLDER"
  sudo mkdir -p $BACKUP_FOLDER/

    if [ -d $BACKUP_FOLDER ]
    then echo "Copying $SOURCE_FOLDER"
    cp -a $SOURCE_FOLDER $BACKUP_FOLDER/

      if [ ! -d $BACKUP_FOLDER/hostapd ]
      then echo -e "\n${Error}ERROR${Off} Failed to copy $SOURCE_FOLDER folder"
      echo "   Exiting..."
      exit 1
      else echo "Successfully copied $SOURCE_FOLDER folder"
      fi

    else echo -e "\n${Error}ERROR${Off} Failed to create $BACKUP_FOLDER folder"
    echo "   Exiting..."
    exit 1
    fi

  else echo "Found a previous backup..."

    if compn -G $BACKUP_FOLDER* > /dev/null 2>&1
    then echo "$SOURCE_FOLDER was previously backed up"
    echo "Appending ${DATE} to new backup"
    sudo mkdir -p $BACKUP_FOLDER-$DATE
    cp -a $SOURCE_FOLDER $BACKUP_FOLDER-$DATE/
    elif [ -n "$(find . -maxdepth 1 -type d -name '$BACKUP_FOLDER*' -print -quit)" ]
    then echo "$SOURCE_FOLDER was previously backed up"
    echo "Appending ${DATE} to new backup"
    sudo mkdir -p $BACKUP_FOLDER-$DATE
    cp -a $SOURCE_FOLDER $BACKUP_FOLDER-$DATE/
    else echo "Copying $SOURCE_FOLDER"
    cp -a $SOURCE_FOLDER $BACKUP_FOLDER-$DATE/
    fi

  fi

else echo -e "\n${Error}ERROR${Off} Unable to locate $SOURCE_FOLDER"
echo "   Exiting..."
exit 1
fi
