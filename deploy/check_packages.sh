#!/bin/bash
# checks for required dependencies
echo "Checking dependencies..."

echo $_break

# check if unzip is installed
source $installunzip || exit 1

echo $_break

# check if wget is installed
source $installwget || exit 1

echo $_break

# check if hostapd is installed
source $checkhostapd || exit 1

echo $_break

# check if apache2 is installed
source $checkapache || exit 1

echo $_break

# check if apache php module is installed
source $checkapachephp || exit 1 

echo $_break
