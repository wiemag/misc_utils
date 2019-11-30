#!/bin/bash
# Make iso image with musical files from am m3u play list.
# Keep m3u sort order.
# Concept:  prepend file name with zero-padded numbers; use soft links;
# by wm (dif), 2015-07-12, 2019-10-28
#
#sed '/^#/d;s/^/"/g;s/$/"/g' $1 | tr '\n' ' ' | xargs brasero -d &
#sed '/^#/d;s/^/"/g;s/$/"/g' $1 | tr '\n' ' ' > ${1%.m3u}.lst
#cat ${1%.m3u}.lst

#---Intro
VERSION='1.03'
M3U='' 		# list_of_musical_files.m3u
RELDIR=''
function invoke_msg { echo -e "\nRun:\n\t${0##*/} [-i charset] [-o charset] list.m3u | -h\n";}
function options_msg { echo "-i charset, input file names { utf8, ISO-5998-1, ISO-5998-1,... }";
	echo "-o charset, output file names";
	echo -e "Run 'genisoimage -input-charset help' to see all charsets available.\n";
}
function usage_msg {
	echo ${0##*/} Version ${VERSION}; invoke_msg; options_msg;
	echo -e "The script creates an iso image with files as specified\n  in the list.m3u file."
	echo As a lot of CD/DVD players sort files by file name automatically,
	echo "  consecutive numbers are prepended to the file names to ensure"
	echo "  unchanged original file order as defined by playlist 'list.m3u'."
}

[ "$1" == '--help' ] && { usage_msg; exit;}
while getopts ":i:o:hv" flag
do
    case "$flag" in
		i) INCHAR="$OPTARG";;
		o) OUTCHAR="$OPTARG";;
		h) usage_msg; exit;;
		v) echo -e "${0##*/} version ${VERSION}" && exit;;
	esac
done
# Remove the options parsed above.
shift $((OPTIND - 1))
(( $# )) || { invoke_msg; echo -e "\e[1;31mMissing file name.\e[0m" ; exit;}

M3U="$1"
[[ ! -f "$M3U" ]] && { echo; echo File $M3U does not exist.; invoke_msg; exit;}
sed -i -e 's/%20/ /g' \
	-e 's/%C4%85/ą/g' \
	-e 's/%C4%87/ć/g' \
	-e 's/%C4%86/Ć/g' \
	-e 's/%C4%99/ę/g' \
	-e 's/%C3%B3/ó/g' \
	-e 's/%C5%9B/ś/g' \
	-e 's/%C5%84/ń/g' \
	-e 's/%C5%82/ł/g' \
	-e 's/%C5%81/Ł/g' \
	-e 's/%C5%BA/ź/g' \
	"$M3U"
RELDIR="${M3U%/*}"
echo DEBUG \$M3U=$M3U
echo DEBUG \$RELDIR=$RELDIR
[[ "$RELDIR" == "$M3U" ]] && RELDIR=''
#RELDIR="/"

#---Down to business
TMPD=$(mktemp -d) 		 # A unique temporary folder for sym-links
N=$(grep -E -vc '^#.*'\|'^ *$' "$M3U") # Number of files specified in .m3u
R=1; while ((N/10)); do N=$((N/10)); ((R++)); done

#---Create numbered sym-links
i=0;
while read L; do
	((i++))
	[[ ${L:0:1} != '/' ]] && L=$(pwd)"/${RELDIR}/$L"
	[[ -f "$L" ]] && {
	ln -s "$L" "$(printf "%s%.${R}d %s" "${TMPD}/" $i "${L##*/}")"
	printf "%.${R}d %s\n" $i "${L##*/}";
	} || echo "Error: '$L' does not exist."
done < <(grep -E -v '^#.*'\|'^ *$' "$M3U")

#---Make ISO (-f = follow symlinks)
DATE=$(date +%Y%m%d)
ISO="${M3U##*/}"
ISO=/tmp/"${ISO%.m3u}_${DATE}.iso"
genisoimage -f -rJ -V $DATE -o "$ISO" "$TMPD"

(( $? )) || {
	echo; echo -e "\e[1;33mFile '$ISO' has been created.\e[0m"
	#LC_NUMERIC=en_US printf "The file size is %'d bytes.\n" $(stat -c%s "$ISO")
	echo "The file size is "$(echo $(stat -c%s "$ISO") | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')" bytes."
}

# Remove $TMPD
rm -r "$TMPD"
