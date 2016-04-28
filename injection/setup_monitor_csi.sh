#!/usr/bin/sudo /bin/bash
modprobe -r iwlwifi mac80211 cfg80211
#modprobe iwlwifi connector_log=0x1 
modprobe iwlwifi connector_log=0x5 #cis + package payload

# Setup monitor mode, loop until it works
iwconfig wlan0 mode monitor 2>/dev/null 1>/dev/null
while [ $? -ne 0 ]
do
	iwconfig wlan0 mode monitor 2>/dev/null 1>/dev/null
done
iw wlan0 set channel $1 $2
#iwconfig wlan0 channel $1
ifconfig wlan0 up
iwconfig wlan0 channel $1

