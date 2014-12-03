#!/bin/bash
# Check my external ip
VERSION='v0.3'
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

IFACE=$(echo $(ip route)|cut -d" " -f5)

while getopts  ":lgiV" flag
do
    case "$flag" in
        i) echo $IFACE; exit;;	# interface
        l) ip a show $IFACE | awk '$1 == "inet" { split($2, a, "/"); print a[1]; }'; exit;;   	# local IP
        g) : ;;  	# global IP
        V|v) echo "Version ${VERSION}"; exit;;
        *) usage; exit;;
    esac
done

# --- External/Internet IP ---------------
if [ -f `whereis curl | cut -d" " -f2` ] ; then
	IP=$(curl -s checkip.dyndns.org)
else
	if [ -f `whereis wget | cut -d" " -f2` ] ; then
		IP=$(wget -q -O - checkip.dyndns.org)
		IP=${IP#*: }; IP=${IP%%<*}
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
IP=${IP#*: }
echo ${IP%%<*}

# --- Local IP ---------------------------
if [[ -z $1 ]]; then
	ip a show $IFACE | awk '$1 == "inet" { split($2, a, "/"); print a[1]; }'
	echo $IFACE
fi

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
