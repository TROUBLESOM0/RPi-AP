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
echo "No connection to Cloudflare."
echo "Starting sta-ap"
exit 1
# If network is connected
else echo "successful ping to Cloudflare."
echo "Starting subcloud"
echo "run test scritp"
./test
fi
else
echo "successful ping to Google"
echo "Starting subcloud"
echo "run test script"
./test
fi
exit 0
