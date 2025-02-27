#!/bin/bash
#
# check-net.sh v.1
# Check network connection by pinging Google or Cloudflare
#
# Checking for root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
#logs
if [[ ! -f /usr/local/etc/RPi-ap/sta-ap/log ]]
then
touch /usr/local/etc/RPi-ap/sta-ap/log
echo "$(date)---First Run check-net.sh---" >> /usr/local/etc/RPi-ap/sta-ap/log
else echo "" >> /usr/local/etc/RPi-ap/sta-ap/log
echo "$(date)---RUNNING CHECK-NET---" >> /usr/local/etc/RPi-ap/sta-ap/log
fi
exec > >(tee -a /usr/local/etc/RPi-ap/sta-ap/log) 2>&1
#
# variables
dir=/usr/local/etc/RPi-ap/sta-ap
ap=/var/www/html
bk=$dir/pre-sys-bkup
#
# check for required files
if [[ -f $dir/sta-ap.start ]]
then :
else echo "missing sta-ap.start"
exit 1
fi
if [[ -f $dir/sta-ap.stop ]]
then :
else echo "missing sta-ap.stop"
exit 1
fi
#
#############################################
#              Begin Script                 #
#############################################
ping -c 1 8.8.8.8 &> /dev/null
# ping Google and check result with $?
if [ $? -ne 0 ]
then
# If ping fails
echo "No connection to Google, trying Cloudflare"
sleep 10
ping -c 1 1.1.1.1 &> /dev/null
  if [ $? -ne 0 ]
  then
  echo "No connection to Cloudflare, trying hostap"
    if [[ ! -f /etc/hostapd/hostapd.conf ]]
    then
    echo "hostap doesn't exist."
    bash $dir/sta-ap.start
    exit 0
    else echo "hostap exists. Wifi Login should be running"
      if [[ -f $ap/login.data ]]
      then
      echo "login.data exists"
      bash $dir/sta-ap.stop
      exit 0
      else echo "...waiting for input"
      exit 0
      fi
    fi
  # If network is connected
  else echo "successful ping to Cloudflare."
  echo "checking if need to stop AP"
    if [[ -f $ap/login.data ]]
    then
    echo "login.data exists"
    bash $dir/sta-ap.stop
    exit 0
    else echo "login.data missing. Waiting for input..."
    exit 0
    fi
  fi
else echo "successful ping to Google."
echo "checking if need to run AP"
  if [[ -f $ap/login.data ]]
  then
  echo "login.data exists"
  bash $dir/sta-ap.stop
  exit 0
  else echo "login.data absent. Waiting for input..."
  exit 0
  fi
fi
echo "Hold My Beer"
exit 0
