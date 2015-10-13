sudo modprobe -r iwlwifi mac80211
sudo modprobe iwlwifi connector_log=0x1
sudo iwconfig wlan1 essid TP5G3
sudo dhclient wlan1
sudo ping -n -i 0.01 192.168.0.4 


#note: use ifconfig to check your wifi device name, if maybe wlan0 or wlan1 

##injection mode 
receiver:
	./setup_monitor_csi.sh 64 HT20
	sudo ../netlink/log_to_file log.dat

    transmitter:
	./setup_inject.sh 64 HT20
	echo 0x4101 | sudo tee `find /sys -name monitor_tx_rate`
	sudo ./random_packets 1 100 1

#note: befere running config, su command should be used 
sudo su


##
roscore 
##receive csi data
rosrun  sar_localization log_csi_stream 

#receive imu data with logging
roslaunch imu_3dm_gx4 imu.launch 
or 
#receive imu data without logging 
imu_3dm_gx4 imu_3dm_gx4 


#run estimator-ekf based 
rosrun wifi_ekf wifi_ekf
or 
#run estimator slam-based
rosrun wifi_estimator wifi_estimator


#log payload data  https://dhalperi.github.io/linux-80211n-csitool/faq.html
12. Can I log other information like payloads or sequence numbers for received packets? [−]

First, please read #5 – "For which packets is CSI measured?". This answer provides useful background for understanding the relationship and interleaving between CSI measurements and other logs.

You can find the information that may be logged by looking at the iwl-connector.h header file in the driver folder. Each of these flags may be set to relay one or more types of messages from the kernel to userspace programs like log_to_file.

The default setting is IWL_CONN_BFEE_NOTIF_MSK -- the beamforming information feedback is logged. Other options:

Enabling IWL_CONN_RX_PHY_MSK will log additional physical information. However, we already copy the most relevant information from this structure into the beamforming response (see code here).
Enabling IWL_CONN_RX_MPDU_MSK will log packet payloads. This message should include, e.g., the IEEE 802.11 sequence number and of course packet payload which you could use for application or measurement-specific purposes.
... other masks log other information, which it will benefit you the user to discover by reading the kernel. :)


#custom packet
a5, 00, 00, 00, 03, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 1a, 00, 00, 00, 01, 00, 00, 00, 00, 00, 00, 00, 2e, 7f, 00, 00, 81, 00, 00, 00, c1, 08, 00, 2c, 00, 00, 16, ea, 12, 34, 56, 00, 16, ea, 12, 34, 56, ff, ff, ff, ff, ff, ff, 00, 00, 37, 38, 39, 3a, 3b, 3c, 3d, 3e, 3f, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 4a, 4b, 4c, 4d, 4e, 4f, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 5a, 5b, 5c, 5d, 5e, 5f, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 7a, 7b, 7c, 7d, 7e, 7f, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 8a, 8b, 8c, 8d, 8e, 8f, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 9a, ce, 03, 36, db, 00, 00, 00,

0: 0xc1
1-5: 08, 00, 2c, 00
6-11: addr1, 00, 16, ea, 12, 34, 56,
12-17: addr2, 00, 16, ea, 12, 34, 56,
18-23: addr3, ff, ff, ff, ff, ff, ff
24-25, don't know, 00, 00
26->-- custom data 






