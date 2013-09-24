#!/bin/bash
# Check my external ip
# v0.1

# --- External/Internet IP ---------------
if [ -f `whereis wget | cut -d" " -f2` ] ; then 
	wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
else
	if [ -f `whereis curl | cut -d" " -f2` ] ; then 
		curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
	else
		echo
		echo Missing dependencies.
		echo Install \"wget\" or \"curl\".
		if [ -f `whereis iproute2 | cut -d" " -f2` ]; then
			echo Package \"iproute2\" is missing, too.
		fi
		echo
		exit 1
	fi
fi
# --- Local IP ---------------------------
#IFACE=wlan0
IFACE=$(echo $(ip route)|cut -d" " -f5)
ip a show dev $IFACE | awk '$1 == "inet" { split($2, a, "/"); print a[1]; }'
echo $IFACE

# --- External/Internet IP methods -------
# Method 1
#wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
# Method 2
#curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
# Method 3
#curl -s http://www.showmyip.ws | grep -A1 "Your Ip" | cut -d">" -f3|cut -d"<" -f1|grep .
# Method 4
#curl http://sputnick-area.net/ip
# Method 5
#curl -s ifconfig.me/all|grep ip_addr|sed  's/ip_addr: //'
