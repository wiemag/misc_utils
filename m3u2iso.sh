#!/bin/bash
# Make iso image with musical files from am m3u play list.
# Keep m3u sort order.
# Concept:  prepend file name with zero-padded numbers; use soft links;
# by wm (dif), 2015-07-12
#
#sed '/^#/d;s/^/"/g;s/$/"/g' $1 | tr '\n' ' ' | xargs brasero -d &
#sed '/^#/d;s/^/"/g;s/$/"/g' $1 | tr '\n' ' ' > ${1%.m3u}.lst
#cat ${1%.m3u}.lst

#---Intro
VER='0.99'
function invoke_msg { echo -e "\nRun:\n\t${0##*/} list.m3u | -h\n";}
function usage_msg {
	echo ${0##*/} Version ${VER}; invoke_msg
	echo -e "The script creates an iso image with files as specified\n  in the list.m3u file."
	echo As a lot of CD/DVD players sort files by file name automatically,
	echo "  consecutive numbers are prepended to the file names to ensure"
	echo "  unchanged original file order."
}
[[ $# -eq 0 ]] && { invoke_msg; exit;}
[ "$1" == '-h' -o "$1" == '--help' ] && { usage_msg; exit;}
[[ ! -f $1 ]] && { echo; echo $1 does not exist.; invoke_msg; exit;}

#---Down to business
TMPD=tmp.m3u_list        # Temporary folder for hard links
N=$(grep -vce '^#.*' $1) # Number of files specified in .m3u
R=1; while ((N/10)); do N=$((N/10)); ((R++)); done
if [[ $(ls -A $TMPD 2>/dev/null) ]]; then
	echo -e "\nWarning! File '$TMPD' exists and is not empty."
	echo You need to empty or remove it.
	exit
fi
mkdir -p $TMPD
D=$(pwd);
i=0;
while read L; do
	if [[ ! "$L" == '#'* ]]; then
		((i++))
		ln -s "$L" "$(printf "%s%.${R}d %s" "${D}/${TMPD}/" $i "${L##*/}")"
		printf "%.${R}d %s\n" $i "${L##*/}"
	fi
done < $1

#---Make ISO (-f = follow symlinks)
DATE=$(date +%Y%m%d)
ISO="${1%.m3u}_${DATE}.iso"
genisoimage -f -rJ -V $DATE -o "$ISO" "$TMPD"
(( $? )) || {
	echo; echo File "$ISO" has been created.
	#LC_NUMERIC=en_US printf "The file size is %'d bytes.\n" $(stat -c%s "$ISO")
	echo "The file size is "$(echo $(stat -c%s "$ISO") | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')" bytes."
}

#---Extra options (use brasero)
if [ "$2" == '-b' -a $(which brasero 2>/dev/null) ]; then
	ls -A $TMPD | sed 's/^/"'${D//\//\\\/}\\\/${TMPD}'\//g;s/$/"/g' \
		| tr '\n' ' ' > "${1%.m3u}.lst"
	#genisoimage -rJ -o "${1}_lsst.iso" -path-list ${1%.m3u}.lst
	echo -e "\n'brasero' will be invoked to burn a disk or make an iso image."
	echo "Don't forget to remove ${TMPD} when you finish."
	read -p "This program is fininshing now... Press any key."
	cat ${1%.m3u}.lst |xargs brasero -d &
	sleep 3
	rm ${1%.m3u}.lst
else
	# Remove $TMPD
	rm -r "$TMPD"
fi