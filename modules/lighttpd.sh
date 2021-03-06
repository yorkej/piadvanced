#!/bin/sh
## Lighttpd
NAMEOFAPP="lighttpd"
WHATITDOES="Lightweight open-source web server. It is used by the Pi-hole project."

## Current User
CURRENTUSER="$(whoami)"

## Dependencies Check
sudo bash /etc/piadvanced/dependencies/dep-whiptail.sh

## Variables
source /etc/piadvanced/install/firewall.conf
source /etc/piadvanced/install/variables.conf
source /etc/piadvanced/install/userchange.conf

{ if 
(whiptail --title "$NAMEOFAPP" --yes-button "Skip" --no-button "Proceed" --yesno "Do you want to setup $NAMEOFAPP? $WHATITDOES" 10 80) 
then
echo "$CURRENTUSER Declined $NAMEOFAPP" | sudo tee --append /etc/piadvanced/install/installationlog.txt
echo ""$NAMEOFAPP"install=no" | sudo tee --append /etc/piadvanced/install/variables.conf
else
echo "$CURRENTUSER Accepted $NAMEOFAPP" | sudo tee --append /etc/piadvanced/install/installationlog.txt
echo ""$NAMEOFAPP"install=yes" | sudo tee --append /etc/piadvanced/install/variables.conf

## Below here is the magic.
LIGHT_BIND=`sed -n '/server.port                 = 80/=' /etc/lighttpd/lighttpd.conf`
whiptail --msgbox "What ports do you want Lighttpd to use?" 10 80 1
whiptail --msgbox "I suggest setting port 80 to the static ip of wlan0" 10 80 1
NEW_LIGHTTPDBIND=$(whiptail --inputbox "Add server.bind for the wlan lighttpd" 10 80 "$NEWETH_IP" 3>&1 1>&2 2>&3)
NEW_LIGHTTPD80=$(whiptail --inputbox "Change the default port 80 for lighttpd" 10 80 "80" 3>&1 1>&2 2>&3)
sudo apt-get install -y lighttpd
sudo echo "NEW_LIGHTTPDBIND=$NEW_LIGHTTPDBIND" | sudo tee --append /etc/piadvanced/install/variables.conf
sudo echo "NEW_LIGHTTPD80=$NEW_LIGHTTPD80" | sudo tee --append /etc/piadvanced/install/variables.conf
sudo cp -r /etc/lighttpd/ /etc/piadvanced/backups/lighttpd/
sudo sed -i "$LIGHT_BIND a\server.bind                 = "$NEW_LIGHTTPDBIND"" /etc/lighttpd/lighttpd.conf
sudo sed -i "s/80/$NEW_LIGHTTPD80/" /etc/lighttpd/lighttpd.conf

## End of install
fi }

## Unset Temporary Variables
unset NAMEOFAPP
unset CURRENTUSER
unset WHATITDOES

## Module Comments
