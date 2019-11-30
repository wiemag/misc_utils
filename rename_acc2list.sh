#!/bin/bash -
#===============================================================================
#          FILE: ren_acc2list.sh
#         USAGE: ./ren_acc2list.sh -f FILTER -l LIST -r -b -o
#   DESCRIPTION: Rename a sorted list of files according to a list of file names
#                in a text file.
#       OPTIONS: -f filter_pattern -l file_list -r -b -O
#  REQUIREMENTS: sed, grep
#          BUGS: ---
#         NOTES: Written and intended for renaming of a series of pdf files
#                containing technical drawings. Use can be more general.
#        AUTHOR: Wiesław Magusiak
#       CREATED: 2014-05-30, 14:50
#===============================================================================

set -o nounset                              # Treat unset variables as an error

RUN=0 				# Run dry, withouth actual renaming.
REVRS='' 			# Reverse the list of file names. Don't uness $REVS == '-r'.
BACKUP=0 			# Don't back up original files as OLDNAME.bak.
OVERWRITE=0 		# Don't overwrite target files with NEWNAME. Create NEWNAME.bak.
LIST='list' 		# Default list name
VERSION=v1.0

MSG="Usage:
\t${0##*/} [-f FILTER] [-l LIST] [-R] [-r] [-O] [-b]
\t${VERSION}, 2014-05-30
Where:
\tFILTER - a pattern to filter files to be renamed
\t         \e[33mNote:  Files named '*.bak' and '*~' are ignored.
\t         Put FILTER in quotation marks.\e[0m
\t         Default: '\e[1mpdf_*\e[0m'
\tLIST   - a text file with a list of new file names
\t         Default: '\e[1mlist\e[0m'
\te      - \e[1me\e[0mextension if not in the LIST
\tR      - \e[1mR\e[0meverts the list of file names
\tr      - if used, actual renaming is done
\tO      - \e[1mO\e[0mverite target files if NEWNAME files exist.
\t         Default: Back up target file-names files if they exist.
\tb      - \e[1mb\e[0mack up original files as OLDNAME.bak\n"

[[ -z $@ ]] && { echo -e "$MSG"; exit;}

while getopts  ":f:l:Re:rObh" flag; do
	case "$flag" in
		f) FILTER="$OPTARG";; 	# A pattern to filter files to be renamed
		l) LIST="$OPTARG";; 	# A text file with a list of names for files
		R) REVRS="-r";; 		# Reverse the list if names
		e) EXT="$OPTARG";; 		# New file name extension if not in the $LIST
		r) RUN=1;; 				# Rename. If 0, the script will do a dry run.
		O) OVERWRITE=1;; 		# Overwrite targets.
		b) BACKUP=1;; 			# Backup original files, but add the .bak extension
		h) echo -e "$MSG" && exit;;
	esac
done

## Set variables ###########################
FILTER=${FILTER-pdf_*}
if [ ! -f $LIST ]; then
	echo -e "$MSG \nFile \'$LIST\' does not exist."
	exit
fi
EXT=${EXT-}
if [[ "x$EXT" = x[bB][aA][kK] ]]; then
	echo -e "$MSG"
	echo -e "\e[31;1mExtension '${EXT}' not allowd.\e[0m"
	exit
fi
[[ -n $EXT ]] && EXT=".$EXT"

#echo FILTER=$FILTER
#echo LIST="$LIST"
#echo EXT=$EXT
#ls $FILTER

## Start the job ###########################
echo Renaming list$( (($RUN)) || echo " (Dry run)"):
i=0
for OLDNAME in $(ls $REVRS -v $FILTER|grep -v "\."[bB][aA][kK]$|grep -v ~$); do
	((++i))
	#NEWNAME=$( [[ $REVRS -eq 0 ]] && cat "${LIST}" |sed -n ${i}p || tac "${LIST}" |sed -n ${i}p)
	NEWNAME=$( cat "${LIST}" |sed -n ${i}p )
	if [[ -n $NEWNAME ]]; then
		printf "  %s%*s==>  %s" \
			"$OLDNAME" $((16>${#OLDNAME}?16-${#OLDNAME}:1)) ' ' "${NEWNAME}${EXT}"
		if [ -f "${NEWNAME}${EXT}" ]; then
			echo ' WARNING: File exists!'
			OVERWRITE=0 	# Just in case the user doesn't know what he/she is doing.
		else
			echo
		fi
		if (($RUN)); then
			(($BACKUP)) && cp "$OLDNAME" "${OLDNAME}.bak"
			(($OVERWRITE)) || \
				{ [[ -f "${NEWNAME}${EXT}" ]] && mv "${NEWNAME}${EXT}" "${NEWNAME}${EXT}.bak";}
			mv "$OLDNAME" "${NEWNAME}${EXT}"
		fi
	else
		echo "The list of new names is SHORTER than the number of filtered files."
		((--i))
		break
	fi
done
echo "$i files $( (($RUN)) || echo "to be ")renamed."
[[ -n $(cat ${LIST}|sed -n $((++i))p) ]] && {
	echo "The list of new names is LONGER that the number of filtered files.";
	echo -e "\e[1mMake sure that the filter pattern is surrounded by apostrophies.\e[0m";
}
