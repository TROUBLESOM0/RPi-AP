#!/bin/bash
#
# Check network connection by pinging Google or Cloudflare
#
# chech for required files
if [[ -f sta-ap.start ]]
then :
else echo "missing sta-ap.start"
exit 1
fi
if [[ -f sta-ap.stop ]]
then :
else echo "missing sta-ap.stop"
exit 1
fi
# Checking for root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
# variables
dir=`pwd`
ap=/var/www/html
bk=$dir/pre-apsta-bkup
#
# Begin Script
#
ping -c 1 8.8.8.8 &> /dev/null
# ping Google and check result with $?
if [ $? -ne 0 ]
then
# If ping fails
echo "No connection to Google, trying Cloudflare"
ping -c 1 1.1.1.1 &> /dev/null
  if [ $? -ne 0 ]
  then
  echo "No connection to Cloudflare, trying apsta-bkup directory"
    if [[ ! -d $bk ]]
    then
    echo "Starting sta-ap"
    sudo ./sta-ap.start
    exit 0
    else echo "apsta-bkup exists. Wifi Login should be running"
      if [[ -f $ap/login.data ]]
      then
      echo "login.data exists"
      sudo ./sta-ap.stop
      exit 0
      else echo "...waiting for input"
      exit 0
      fi
    fi
  # If network is connected
  else echo "successful ping to Cloudflare."
  echo "checking if need to run sta-ap.stop"
    if [[ -f $ap/login.data ]]
    then
    echo "login.data exists"
    sudo ./sta-ap.stop
    exit 0
    else exit 0
    fi
  fi
else echo "successful ping to Google."
echo "checking if need to run sta-ap.stop"
  if [[ -f $ap/login.data ]]
  then
  echo "login.data exists"
  sudo ./sta-ap.stop
  exit 0
  else exit 0
  fi
fi
exit 0
