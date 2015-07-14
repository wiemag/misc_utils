#!/bin/bash
# Check who else is on the local network.
[[ $(which nmap 2> /dev/null) ]] || { echo Missing dependency. Install \'nmap\'.; exit;}
BITS=${1-25} 	# 25 is default (25 leading 1's if the IP mask)
[[ $BITS -gt 31 ]] && BITS=31 || [[ $BITS -lt 24 ]] && BITS=24
x=$(ip r|awk '/default/ {print $3}')
x=${x%.*}.0/$BITS
MAX=1
for (( i=$((32-BITS)); i--;  )); { MAX=$((MAX*2));}
MAX=$((MAX-1)) 	# The last possible host number on the local net as set by the mask.
echo LAN hosts being up on $x \(0..${MAX}\)
nmap -sP $x
