#!/bin/bash - 
#===============================================================================
#
#          FILE: album2songs.sh
#         USAGE: ./album2songs.sh
#
#   DESCRIPTION: Cuts album ${file} from youtube according
#                to end times as written in a ${file}.txt
#                <end time1> <song1>
#                <end time2> <song2>...
#       CREATED: 17.01.2017
#         TO DO: check if input file is audio media
#                retrieve bitrate form original and use it in conversion
#                use -q:a N for conversion (decide what N algorythm)
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=1.00
function secondize () {
    PARAM=:$1
    s=0
    for ((i=1; ${#PARAM} > 0 ; i=$((i * 60)) )); do
        m=${PARAM##*:}
        [[ ${#m} -eq 2 ]] && m=${m#0}
        s=$(( $s + $m * $i))
        PARAM=${PARAM%:*}
    done
    echo $s
}
function usage() {
	echo "Version "$version
	echo Usage:
	echo -e "\t${0##*/} album [artist [bit_rate]]\n"
	echo -e "\${\e[1malbum\e[0m} has to have be audio-media file."
	echo -e "\${\e[1malbum\e[0m}.\e[1mtxt\e[0m holds time stamps."
	echo Time stamps file format:
	echo -e "\t<end time 1> <song title 1>"
	echo -e "\t<end time 2> <song title 2>"
	echo -e "\t..."
	echo If option \"artist\" is not given, it defaults to \"album\".
	echo -e "\e[1mbit_rate\e[0m does not need to have the \"k\" suffix."
}
album="${1-}"              # <album.m4a> to be cut in to songs
[[ -e "$album" ]] || { usage; exit 1;}
artist="${album%.*}"	# Temporary artist name
stamps="${artist}.txt"  # <album.txt> that should contain time stamps.
[[ -e "$stamps" ]] || { echo $stamps does not exist.; usage; exit 2;}
declare -a songs
declare -a endts
artist="${2-$artist} - "    # Artist if defined; album name if not.
[[ -n ${3-""} ]] && bitrate="-b:a ${3%[kK]}k" || bitrate="-q:a 4"
startt=0     # a song start time
length=0     # a song length
i=0
while read endts[i] songs[i]; do
	# ffmpeg does not stop the loop until conversion is over.
    # Neither does "wait $!" do that.
    # Consequently, another loop has to be used for conversion.
	((++i))
done < "$stamps"
let n=i
k=$(echo -n $((--n))|wc -c) # Number of characters in the last song number.
for ((i=0; i < n; i++)); do
	echo "$(printf "%${k}d" $((++i)))" ${songs[$i]}
	let length=$(secondize ${endts[$i]})-$startt
	ffmpeg -y -i "$album" $bitrate -ss $startt -t $length "${artist}$(printf "%0${k}d" $((++i))) - ${songs[i]}".mp3 2>/dev/null
	startt=$(secondize ${endts[$i]})
done

##====================================================================
# https://trac.ffmpeg.org/wiki/Encode/MP3
#
# lame  Avg  	Bitrate  	ffmpeg
# opt. kbit/s    range      option
# -b 320 320 	320 CBR		-b:a 320k (NB this is 32KB/s, or its max)
# -V 0 	245 	220-260 	-q:a 0 (NB this is VBR from 22 to 26 KB/s)
# -V 1 	225 	190-250 	-q:a 1
# -V 2 	190 	170-210 	-q:a 2
# -V 3 	175 	150-195 	-q:a 3
# -V 4 	165 	140-185 	-q:a 4
# -V 5 	130 	120-150 	-q:a 5
# -V 6 	115 	100-130 	-q:a 6
# -V 7 	100 	 80-120  	-q:a 7
# -V 8   85 	 70-105 	-q:a 8
# -V 9   65 	  45-85 	-q:a 9
##====================================================================
