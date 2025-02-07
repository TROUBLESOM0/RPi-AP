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
# Checking for root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
#
#
# Begin Script
#
ping -c 1 8.8.8.8 &> /dev/null
# $? checks the exit status of the previous command (ping)
if [ $? -ne 0 ]
then
# If ping fails
echo "No connection to Google, trying Cloudflare"
ping -c 1 1.1.1.1 &> /dev/null
  if [ $? -ne 0 ]
  then
  echo "No connection to Cloudflare, trying login.php"
    if [[ ! -f /var/www/html/login.php ]]
    then
    echo "Starting sta-ap"
    echo "#sudo ./sta-ap.start"
    exit 0
    else echo "login.php exists. Wifi Login should be running"
      if [[ -f /var/www/html/login.data ]]
      then
      echo "login.data exists"
      echo "run sta.stop+++++++++++++++"
      else echo "login.data no exists, but login.php should be running...waiting for input"
      exit 0
      fi
    fi
  # If network is connected
  else echo "successful ping to Cloudflare."
  echo "checking if need to run sta-ap.stop"
    if [[ -f /var/www/html/login.data ]]
    then
    echo "login.data exists"
    echo "run sta.stop--------------------"
    else exit 0
    fi
  fi
else echo "successful ping to Google."
echo "checking if need to run sta-ap.stop"
  if [[ -f /var/www/html/login.data ]]
  then
  echo "login.data exists"
  echo "run sta.stop *********************"
  else exit 0
  fi
fi
exit 0
