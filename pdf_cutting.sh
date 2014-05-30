#!/bin/bash

# Cuttung a PDF into chapters
# by dif (wm) 2012-09-23
# based on examon's spdf (spdf-git)
VERSION=0.4 	# modified 2014-05-30; leading zeros in part names

function usemsg () {
	echo Syntax:
	echo -e "\033[1m\tpdf_cutting filename[.pdf] pages_to_break_after\033[m"
	echo -e "Where:\n\tpages_to_break_after - integer numbers separated by spaces"
	exit $1
}

function basepath () {
	#	Works with pathname parameters, as well.
	local p o
	[[ "${1:0:2}" = "./" ]] && o=${1:2} || o=$1
	[[ ${o:0:1} != "/" ]] && o="$(pwd)/$o"
	p="${o%/*}"
	[[ "x$p" == "x" ]] && echo "/" || echo "$p"
}

if [ ! -f $(which spdf 2>/dev/null) ] ; then
	echo
	echo -e "\e[31;1mDependency missing.\e[0m"
	echo Please install \"spdf-git\".
	echo We also recommended package \"jpdf-git\" for joining PDF files.
	echo
	exit 1
fi

n=$#			# number of parameters, including the file name
if (($n < 2)) ; then
	echo -e "\n\e[1mpdf_cutting\e[0m (v${VERSION}) splits a given PDF file into two or more parts."
	echo -e "The original PDF file remains untouched. Cutting is done on a copy.\n"
	usemsg 1
fi
i=0
nn=0			# non-nunerical entries
while [ $i -lt $n ] ; do
	if (("$1")) 2>/dev/null; then 	# Is $1 numeric and more than 0?
		PAGES[$i]=$1
	else
		((nn++));
		if (( nn > 1 )) ; then
			echo Too many non-numerical entries.
			echo There can be only one file name.
			usemsg 3
		fi
		f=${1%.pdf}	 # PDF-file name to be cut
		if [ ! -e "$f.pdf" ] ; then
			echo File \"$f.pdf\" does not exist.
			exit 1
		fi
	fi
	((i++))
	shift
done
if (( nn < 1 )); then
	echo Missing file name.
	usemsg 2
fi

# Sorting pages-to-cut-after (reverse order)
PAGES=($(printf '%s\n' "${PAGES[@]}"|sort -nr))
i=$((${PAGES[0]}+1)) 	# Page number the last part starts in.
PAD=${#i}				# Padding/leading zeros

#echo File to cut: $f.pdf
BASEPATH="$(basepath "$f")"
TMPF="/tmp/pdf_cut_"$(date +%T) 	# Temporary pdf file
TMPF=${TMPF//:/}
cp "$f.pdf" ${TMPF}.pdf
f=$TMPF
i=0
((n--))
while [ $i -lt $n ]
do
	spdf $f.pdf ${PAGES[i]} > /dev/null 2>&1
	if [[ $? -gt 0 ]] ; then 
		echo Can\'t split after page ${PAGES[i]}, out of range.
	else
		echo Cut after page ${PAGES[i]}
		# Dodać zabezpieczenie przeciwko nadpisaniu plików pdf_*.pdf
		mv $f\_part2.pdf "${BASEPATH}/pdf_$(printf "%0*d" $PAD $((${PAGES[i]}+1))).pdf"
		mv $f\_part1.pdf $f.pdf
	fi
	j=$i
	((i++))
	while [ $i -lt $n ] && [ ${PAGES[i]} -eq ${PAGES[j]} ]
	do
		j=$i
		((i++))
	done
done
mv $f.pdf "${BASEPATH}/pdf_$(printf "%0*d" $PAD 1).pdf"
echo Done.
