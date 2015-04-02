#!/bin/bash
# List group membership
# # Based on Paweł Nadolski's post on
# # http://stackoverflow.com/questions/2835368/how-to-list-all-users-in-a-linux-group
#
if [[ -z $1 ]]; then
	echo -e "\nUsage:\n\t${0##*/} GROUP_NAME\n"
	echo List GROUP members.
	echo Use GROUP_NAME to print out the membership list without any comments.
	group=$(id -gn $USER)
	echo -e "\nYour primary group is \e[1;1m${group}\e[0m and the group members are\n"
else
	group=$1
fi
getent passwd | while IFS=: read name trash
do
	groups $name | cut -d:  -f2 | grep -q -w "$group" && echo $name
	#namegroups $name | grep -q -w "$group" && echo $name
done
:
