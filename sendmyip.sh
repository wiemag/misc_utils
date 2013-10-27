#!/bin/bash
# Sends sender's external and local IP's and the active network interface.
# If sent by root, sudo -u $USER /path/to/user's/directory/.../sendmyip.sh.

# DEPENDENCIES
# Command myip:  myip (this package), curl (or wget)
# Command mail:  s-nail (or heirloom-mailx) 
#                and msmtp + sm-c
#                 or mstp-mta
# Command grep:  grep
# Command cut:   coreutils

while getopts  "s:" flag
do
	case "$flag" in
		s) SUBJECT="$OPTARG";; 			# E-mail subject
	esac
done

shift $((OPTIND - 1))
RECIPIENT=${1-$USER}
SUBJECT=${SUBJECT-"Info from $RECIPIENT"}
# If $RECIPIENT is not a qualified domain address, look for the address in /etc/aliases.
if [[ $RECIPIENT == ${RECIPIENT%@*.*} ]]; then
	if [[ -e /etc/aliases ]]; then
		RECIPIENT=$(cat /etc/aliases |grep -v ^\# |grep $RECIPIENT|cut -d" " -f2)
		RECIPIENT=${RECIPIENT%%,*}
		[[ -z $RECIPIENT ]] && exit 4 				# E-mail address not found.
	else
		exit 6 										# /etc/aliases does not exist.
	fi
else
	[[ $RECIPIENT == ${RECIPIENT%@.*} ]] || exit 5 	# Wrong e-mail address.
fi

echo $(myip) | mail -s "$SUBJECT" $RECIPIENT
