#!/bin/bash

rootdir=/usr/local/etc/RPi-AP
install_ap=$rootdir/RPi-AP-install.sh
source $install_ap
echo -e "\nVerifying presence of files..."
if [[ -f $stadir/c_start.sh ]]
then :
else echo "c_start.sh missing"
exit 1
fi

if [[ -f $stadir/check-net.sh ]]
then :
else echo "check-net.sh missing"
exit 1
fi

if [[ -f $stadir/sta-ap.start ]]
then :
else echo "sta-ap.start missing"
exit 1
fi

if [[ -f $stadir/sta-ap.stop ]]
then :
else echo "sta-ap.stop missing"
exit 1
fi

if [[ -f $rootdir/uninstall-ap.sh ]]
then :
else echo "uninstall-ap.sh missing"
exit 1
fi
