#!/bin/bash
FILE="${1-bkp-$(date +%Y%m%d-%H%M).ab}"
if [[ "$FILE" = '-h' ]] || [[ "$FILE" = '--help' ]]; then
	echo Make backup of your android applications.
	echo Usage:
	echo -e "\t${0##*/} [backup-file name]\n"
	echo The default backup file name is \''bkp-$(date +%Y%M%d).ab'\'.
	echo \'bkp-$(date +%Y%m%d-%H%M).ab\' today.
	exit
fi
adb backup -apk -obb -all -shared -f $FILE

#--TUTORIAL---------
#adb backup -all
#This will use the defaults to backup only app and device data
#(not the APKs themselves) to the current directory as 'backup.ab'
#
# -apk|-noapk
# This flags tells adb to include APKs in the backup or just the apps' respective data.
# Use -apk just in case the app isn't available in the Market, so that
# I don't have to go hunt it down again. The default is -noapk.
#
# -shared|-noshared
# This flag is used to enable/disable backup of the device's shared
# storage/SD card contents; the default is noshared. Recommeded -shared.
#
# -system|-nosystem
# This flag sets whether or not the -all flag also includes system applications or not.
# I used -system, but this is probably unnecessary, and I would almost guess that it is
# safer to use -nosystem, but use your own judgment on this. The default is -system.
#
# -obb|-noobb
# enable/disable backup of any installed apk expansion (aka .obb) files associated
# with each application; the default is noobb.
#
# Example
# (linux)   adb backup -apk -shared -all -f ./backup20111230.ab
# (windows) adb backup -apk -shared -all -f C:\backup20111230.ab
#
# RESTORE WITH
# adb restore backup_file_name
