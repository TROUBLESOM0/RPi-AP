#!/bin/bash
#
# RPi-AP-install.sh v.1
#
echo "######################################################################################################"
echo "##    This will install a Local Access Point                                                        ##"
echo "##      for connecting to a WiFi Access Point                                                       ##"
echo "##      via a web browser interface.                                                                ##"
echo "##                                                                                                  ##"
echo "##    This script will perform the following actions:                                               ##"
echo "##    1. Perform initial checks to determine required system programs are installed or present      ##"
echo "##    2. Download a selection of .bash scripts and save in the location:                            ##"
echo -e "##      \033[1;33m/usr/local/etc/RPi-AP\e[0m                                                     ##"
echo "##    3. Setup the RPi-ap-check.service into /etc/systemd/system/ folder to run on boot             ##"
echo -e "##      - this creates a local AP for configuring a wireless connection if none is present       ##"
echo "######################################################################################################"
echo -e "\n\n"
#
#
#
### VARIABLES ###
#################
Error='\033[1;31m'   # Bold red
Off='\033[0m'
USER=${SUDO_USER:-$USER}
this_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
rootdir=/usr/local/etc/RPi-AP
bkupdir=$rootdir/BACKUPS
stadir=$rootdir/sta-ap
start_ap=$stadir/sta-ap.start
stop_ap=$stadir/sta-ap.stop
install_ap=$rootdir/RPi-AP-install.sh
uninstall_ap=$rootdir/uninstall-ap.sh
deploy=$rootdir/deploy
verifyfiles=$deploy/verify_files.sh
checkprevious=$deploy/check_previous.sh
checkpackages=$deploy/check_packages.sh
installunzip=$deploy/Installunzip.sh
installwget=$deploy/Installwget.sh
checkhostapd=$deploy/check_hostapd.sh
hostapdbkup_scr=$deploy/hostapdbkup.sh
installhostapd=$deploy/Installhostapd.sh
checkapache=$deploy/check_apache.sh
installapache=$deploy/Installapache.sh
checkapachephp=$deploy/check_apache-php.sh
installapachephp=$deploy/Installapache-php.sh
installservice=$deploy/Installservice.sh

c_start=$stadir/c_start.sh
check_net=$stadir/check-net.sh
run_check=$stadir/web/run-check.sh
req=required
whtml=$stadir/web/index.html
wlogin=$stadir/web/login.php
ap=/var/www/html

# Change to latest release
gitLink="https://  [ latest release ]"


service=RPi-ap-check.service
_break="---------------"


#
###################
###   ASK_LOG   ###
###################
ask_Log () {
#logs

if [[ ! -f /usr/local/etc/RPi-ap/sta-ap/log ]]
then
echo -e "Creating log file...\n"
touch $stadir/log
echo "$(date)---INSTALLATION FOR RPI-AP---" >> $stadir/log
else echo "" >> $stadir/log
echo "$(date)---RE-INSTALLING RPI-AP---" >> $stadir/log
fi

exec > >(tee -a $stadir/log) 2>&1
}
#
##################
###   ASK_DL   ###
##################
ask_DL () {
echo "Downloading files..."
wget -q $gitLink -P /usr/local/etc/

if [[ -f /usr/local/etc/main.zip ]]
then :
else echo -e "\n***ERROR:  Download failed. Run installation again."
exit 1
fi

unzip -qq -o /usr/local/etc/main.zip -d /usr/local/etc/

if [[ -d /usr/local/etc/RPi-AP-main ]]
then :
else echo -e "\n***ERROR: There was an issue extracting the downloaded .zip file in /usr/local/etc/."
echo "Run installation again."
exit 1
fi

mv /usr/local/etc/RPi-AP-main/ /usr/local/etc/RPi-AP
rm /usr/local/etc/main.zip

if [[ -d $rootdir ]]
then echo "Download complete"
fi

# REMOVE README FROM ROOT
# 



# add sudo file to /etc/sudoers.d/
if [[ ! -f /etc/sudoers.d/010_RPi-ap ]]
then echo "Adding permission to sudoers.d"
cp $stadir/$req/010_RPi-ap /etc/sudoers.d/010_RPi-ap
chmod 440 /etc/sudoers.d/010_RPi-ap
  if [[ -f /etc/sudoers.d/010_RPi-ap ]]
  then echo "sudoers file added"
  else echo "***ERROR adding sudoers file***"
  fi
else echo "sudoers file already exists"
echo "updating..."
rm /etc/sudoers.d/010_RPi-ap
cp $stadir/$req/010_RPi-ap /etc/sudoers.d/010_RPi-ap
chmod 440 /etc/sudoers.d/010_RPi-ap
  if [[ -f /etc/sudoers.d/010_RPi-ap ]]
  then echo "sudoers file updated"
  else echo "***ERROR updating sudoers file***"
  fi
fi

#########################
# Configure Permissions #
#########################
chmod u+x,g+x $c_start
chmod u+x,g+x $check_net
chmod u+x,g+x $start_ap
chmod u+x,g+x $stop_ap
chown root:www-data $run_check
chmod u+rw,g+rx,o+r $run_check
chmod u+rwx,g+rx,o+r $uninstall_ap

}
#
##########################
#      ask_Check-OS      #
##########################
ask_Check-OS () {
echo 
if [[ -f /etc/os-release ]]
then :
else
echo -e "${Error}ERROR${Off} Unable to get OS Version from os-release++"
echo -e "++Will continue but may have compatibility issues++\n"
fi

os_version=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f2)

if [[ $os_version = "buster" ]]
then echo -e "OS Version: Buster (compatible)\n"
elif [[ $os_version = "bullseye" ]]
then echo -e "OS Version: Bullseye (compatible)\n"
elif [[ $os_version = "bookworm" ]]
then echo -e "OS Version: Bookworm (compatible)\n"
elif [[ $os_version = "" ]]
then echo "OS Version (not-found): $os_version (non-compatible)"
read -r -p "Do you still want to continue... (y/n)" incompatible_input
  if [[ ${incompatible_input,,} == "y" || ${incompatible_input,,} == "yes" ]]
  then :
  else exit 0
  fi
else echo -e "OS Version: $os_version may not be compatible\n"
read -r -p "Do you still want to continue... (y/n)" incompatible_input
  if [[ ${incompatible_input,,} == "y" || ${incompatible_input,,} == "yes" ]]
  then :
  else exit 0
  fi
fi

}
#
#################
###  ASK_NET  ###
#################
ask_Net () {
ping -c 1 8.8.8.8 &> /dev/null
if [ $? -ne 0 ]
then echo "Internet Is Required!!!"
exit 0
else :
fi
}
#
######################
#      ask_Start     #
######################
ask_Start () {
read -r -p "Do you want to begin installation of RPi-AP? " start_input
if [[ ${start_input,,} == "y" || ${start_input,,} == "yes" ]]
then :
else exit 0
fi
}
#
#############################################
#              Begin Script                 #
#############################################
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
ask_Start
ask_Net
ask_Check-OS
ask_DL

source $verifyfiles || exit 1
source $checkprevious || exit 1
source $checkpackages || exit 1

echo ""
ask_Log
echo -e "\nConfiguring service in systemd..."
source $installservice || exit 1
echo -e "\nREBOOTING\n"
reboot
exit 0
