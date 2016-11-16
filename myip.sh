#!/bin/bash
# Check my external ip
VERSION='v0.4'
# In Arch Linux the curl package is in the base repository, while the wget in the extra.
#
function usage() {
	echo -e "\n\e[1m${0##*/}\e[0m [-l] [-g] [-i] \e[2m[-V] [-h]\e[0m"
	echo Version $VERSION
	echo ' '-l'    'print local IP \(LAN\)
	echo ' '-g'    'print global/external IP \(WAN\)
	echo ' '-i'    'print interface current name
	echo ' '-V'    'print version number
	echo ' '-h'    'print this usage message
	echo If no options, external IP, local IP, and interface name are printed.
}

function ext-IP() {
	WEBSERVICE="l2.io/ip"
	IP=$(hash dig >/dev/null 2>&1 && dig +short myip.opendns.com @resolver1.opendns.com) || {
		IP=$(hash curl >/dev/null 2>&1 && curl "$WEBSERVICE" 2>/dev/null) || {
			IP=$(hash wget >/dev/null 2>&1 && wget -q -O - "$WEBSERVICE") || {
				echo; echo Missing dependencies.
				echo Install \"bind-tools\", \"curl\" or \"wget\".
				exit 1
			}
		}
	}
	echo $IP
}

function loc-IP() {
	echo $(ip a show $IFACE | awk '$1 == "inet" { split($2, a, "/"); print a[1]; }')
}

IFACE=$(echo $(ip route)|cut -d" " -f5)

while getopts  ":lgwiV" flag
do
    case "$flag" in
        i) echo $IFACE; exit;;	# interface
        l) loc-IP; exit;;   	# local IP
        g|w) ext-IP; exit;;  	# global IP
        V|v) echo "Version ${VERSION}"; exit;;
        *) usage; exit;;
    esac
done

ext-IP
loc-IP
echo $IFACE

# --- External/Internet IP methods -------
# Methods
#wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
#curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
#curl -s http://www.showmyip.ws | grep -A1 "Your Ip" | cut -d">" -f3|cut -d"<" -f1|grep .
#curl http://sputnick-area.net/ip
#curl ifconfig.me/ip
#curl eth0.me
#curl l2.io/ip
