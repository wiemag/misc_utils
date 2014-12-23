#!/bin/bash - 
#===============================================================================
#
#          FILE: album2songs_m4a2mp3.sh
#         USAGE: ./album2songs_m4a2mp3.sh
#
#   DESCRIPTION: Cuts album ${file}.m4a from youtube according
#                to end times as written in a ${file}.txt
#                <end time1> <song1>
#                <end time2> <song2>...
#       CREATED: 18.10.2014 11:54
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.96
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
	echo -e "\t${0##*/} album.m4a [artist [bit_rate]]\n"
	echo -e "\${\e[1malbum\e[0m}.m4a has to have the \e[1mm4a\e[0m extension."
	echo -e "\${\e[1malbum\e[0m}.\e[1mtxt\e[0m holds time stamps."
	echo No other option for time stamps holding file is available!
	echo Time stamps file format:
	echo -e "\t<end time 1> <song title 1>"
	echo -e "\t<end time 2> <song title 2>"
	echo -e "\t..."
	echo If option \"artist\" is not stated, it defaults to \"album\".
	echo -e "\e[1mbit_rate\e[0m does not need to have the \"k\" suffix."
}
album="${1-}"              # <album.m4a> to be cut in to songs
[[ ! -e "$album" ]] || [[ "${album##*.}" != "m4a" ]] && { usage; exit;}
artist="${album%.m4a}"  # Temporary artist name
stamps="${artist}.txt"  # <album.txt> that should contain time stamps.
[[ -e "$stamps" ]] || { echo $stamps does not exist.; usage; exit;}
declare -a songs
declare -a endts
artist="${2-$artist} - "    # Artist if defined; album name if not.
[[ -n ${3-""} ]] && bitrate="-b:a ${3%[kK]}k" || bitrate=""
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
