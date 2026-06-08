#!/bin/bash
# check service file exists
if [[ -f /etc/systemd/system/$service ]]
then echo "removing existing service"
systemctl disable $service
else :
fi

if [[ ! -f $stadir/$req/$service ]]
then echo -e "${Error}ERROR${Off} $service is missing!\n"
exit 1
else
chown root:root $stadir/$req/$service
chmod u+rwx,g+rx,o+r $stadir/$req/$service
sleep 2
ln -s $stadir/$req/$service /etc/systemd/system/$service
sleep 1
echo "enabling service..."
systemctl enable $service
# check for errors on service
echo "checking for errors..."
  if systemctl is-enabled "$service" &>/dev/null
  then echo -e "service is enabled\n"
  else
  echo -e "${Error}ERROR${Off} There was an issue configuring the service '$service'!"
  echo "Run Uninstall script"
  echo -e "Then try re-installing\n"
  exit 1
  fi
fi
