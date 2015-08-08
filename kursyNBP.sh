#!/bin/bash
# Download currency exchange-rate tables for the NBP (the Polish Central Bank)

# List of available tables (Lines end in <CR><LF>).
# <LF> is a separator here; <CR> needs to be removed later in the script.
VERSION=1.00
URL="http://www.nbp.pl/kursy/xml/dir.txt"

[[ $# == 0 ]] && DATE="z$(date +%y%m%d)" || DATE=""
TABLE="" 	# An array of table name files.
YEAR=""  	# The year for which tables will be downloaded.
ALL=0   	# Download all available in 1.

function show_help {
 echo -e "\nDownload the chosen NBP currency exchange-rate table(s)."
 echo -e "\nUsage:\n\t${0##/} [-d DATE] | [-y YEAR] [-a] | [-h|?]\n"
 echo "DATE format:  '[RR]RRMMDD'"
 echo -e "YEAR format:  '[RR]RR'\n"
 echo -e "\n'-d' downloads the exchange-rate table for a given DATE."
 echo "    The default and prioritised option."
 echo "'-y' downloads all currency exchange tables for a given YEAR."
 echo "'-a' downloads all currency exchange tables available."
 echo -e "\n\e[0;32mDefault:\e[1m '-d <current date>'\e[0m"
 exit
}

[[ "$1" = "--help" ]] && show_help && exit

# A POSIX variable
#OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "d:y:ah?" opt; do
    case "$opt" in
    h|\?) show_help; exit 0;;
    d)  DATE="00000$OPTARG"; DATE="z${DATE:${#DATE}-6}"; break;;
    y)  YEAR="000$OPTARG"; YEAR="z${YEAR:${#YEAR}-2}" ;;
    a)  ALL=1;;
    esac
done
#shift $((OPTIND-1))
#[ "$1" = "--" ] && shift
#echo "verbose=$verbose, output_file='$output_file', Leftovers: $@"
# TEST
#echo DATE=$DATE
#echo YEAR=$YEAR
#echo ALL=$ALL

# DOWNLOAD AN EXCHANGE-RATE TABLE FOR A DATE
if [[ -n "$DATE" ]]; then
	TABLE="$(curl -s ${URL} | awk '/a...'${DATE}'/ {print $0}')"
	if [[ -z $TABLE ]]; then
		echo No table for this date.
		exit
	fi
	TABLE=${TABLE:0:${#TABLE}-1} 	# Remove <CR> from the end of the line.
	TABLE=${TABLE}.xml
	curl -s ${URL%/*}/${TABLE} -o ${TABLE}
	[[ $? == 0 ]] && echo ${TABLE} has been downloaded.
else
	if [[ -n $YEAR ]]; then
		TABLE="$(curl -s ${URL} | awk '/a...'${YEAR}'/ {print $0}')"
	else
		TABLE="$(curl -s ${URL} | awk '/a...z/ {print $0}')"
	fi
	for w in $TABLE; do
		w=${w:0:${#w}-1}.xml
		curl -s ${URL%/*}/${w} -o ${w}
		echo $w
	done
fi


#if [[ -n "$TABLE" ]]; then
#	curl -s ${URL%/*}/${TABLE} -o ${TABLE}
#fi
