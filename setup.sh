#!/bin/bash

read -p 'Berkeley email: ' username
read -sp 'Personal eduroam password: ' password
echo

passhash=$(echo -n "$password" | iconv -t utf16le | openssl md4 | grep -oE '[^ ]+$' --color=never)
echo "Generated password hash $passhash."
echo

echo -n "Write config to wpa_supplicant.conf... "
printf "\n\nnetwork={\n\tssid=\"eduroam\"\n\tproto=RSN\n\tkey_mgmt=WPA-EAP\n\teap=PEAP\n\tidentity=\"%s\"\n\tpassword=hash:%s\n\tphase1=\"peaplabel=0\"\n\tphase2=\"auth=MSCHAPV2\"\n\tpriority=1\n}\n" "$username" "$passhash" >> /etc/wpa_supplicant/wpa_supplicant.conf && echo "Done"

echo -n "Enable wpa_supplicant service... "
systemctl enable wpa_supplicant && echo "Done"

read -p 'Reboot now? [y/n] ' rbt

if [[ $rbt == 'y' || $rbt == 'Y' ]]
then
	reboot
else
	echo Reboot aborted. Please reboot later to apply wpa_supplicant changes.
fi
