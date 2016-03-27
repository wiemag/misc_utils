#!/bin/bash
# Compresses a list of files into a 7z file, password-protecting the file list and the contents.
VERSION=0.1
FILE="$1"
ARGN=$#

function usage_msg(){
	echo -e "\nUsage:\n\t${0##*/} file_to_be_compessed"
	echo or
	echo -e "\t${0##*/} ARCHIVE[.7z] list_of_files_to_be_compressed"
	echo -e "\nIf ARCHIVE has no extension .7z is appended automatically."
	echo ARCHIVE\[.7z\] can\'t exist, otherwise the script is stopped.
}

# -p  	# Ask for password
# -mhe  # Hide file list
if [[ $ARGN -eq 0 ]]; then
	usage_msg
else
	[[ $@ =~ '*' ]] || [[ $@ =~ '?' ]] && { echo $@ not resolved; exit;}
	if [[ $ARGN -eq 1 ]]; then
		[[ -e "$FILE" ]] || { echo File \'$FILE\' not found.; exit 2;}
		[[ -d "$FILE" ]] && FILE="${FILE%/}"
		FILE=${FILE%.*}.7z
		[[ -f "$FILE" ]] && ! file "$FILE" |grep 7-zip > /dev/null &&
			{ echo \'${FILE}\' already exists.; exit 1;}
	else
		[[ -f "$FILE" ]] && ! file "$FILE" |grep 7-zip > /dev/null &&
			{ echo \'${FILE}\' already exists.; usage_msg; exit 1;}
		EXT=${FILE##*.};
		[[ ${EXT,,} != 7z ]] && FILE=${FILE}.7z
		[[ -f "$FILE" ]] && ! file "$FILE" |grep 7-zip > /dev/null &&
			{ echo \'${FILE}\' already exists.; usage_msg; exit 1;}
		shift
		for f in "$@"; do
			[[ -e "$f" ]] || { echo $f does not exist. Aborting...; exit;}
		done
	fi
	7z a "$FILE" "$@" -mhe -p
	#echo Done. Checking...
	#7z t "$FILE"
fi
