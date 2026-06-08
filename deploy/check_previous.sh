#!/bin/bash
# checks for previous installation
if test ! -f $stadir/$start_ap
then return
else echo "RPi-AP appears to already be installed on this device."
fi

read -p "Do you want delete and re-install? [y/n]" install_input
#convert to lowercase
if [[ "${install_input,,}" == "y" || "${install_input,,}" == "yes" ]]
then 
#
#    COMMAND TO REMOVE RPi-AP
#    MUST INSTALL BECAUSE WILL EXIT ON "NO"
#
else exit 0
fi
