#!/bin/bash

function help_msg(){
cat <<MSG

${0##*/} [-f] FILE1 [FILE2 [FILE3 [...]]]

The script renames file names by moving the leading part of the name to the end.
The '-f' means the leading part ends in the FIRST space character of the file name.
Otherwise/By default, the leading part ends in the LAST space.

MSG
}

[ "$1" = '-h' -o "$1" = '--help' ] && { help_msg; exit;}
[[ "$1" == '-f' ]] && { FIRST=1; shift;} || FIRST=0
[[ $# -eq 0 ]] && { echo Missing file name\(s\).; help_msg; exit 1;}

for FILE in "$@"; do
	[[ -e "$FILE" ]] && {
	EXT=${FILE##*.}
	(($FIRST)) &&
		NEWN=$(sed -E 's/(^[^ ]+) (.+)(\.'$EXT')/\2_\1.'$EXT'/' <<< "$FILE") ||
		NEWN=$(sed -E 's/(^.+) (.+)(\.'$EXT')/\2_\1.'$EXT'/' <<< "$FILE")
	NEWN=${NEWN// /_}
	[[ -e "$NEWN" ]] &&
		{ echo File \'$NEWN\' already exists. No renaming.;} ||
		mv "$FILE" "$NEWN"
	echo $NEWN
 	} || {
 		echo File \'$FILE\' not found!
	}
done
