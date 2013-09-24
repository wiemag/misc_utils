#!/bin/bash

# Cuttung a PDF into chapters
# by dif (wm) 2012-09-23, modified 2013-07-19
# based on examon's spdf (spdf-git)
VERSION=0.1

function usemsg () {
	echo Syntax:
	echo -e "\033[1m\tpdf_cutting filename[.pdf] pages_to_break_after\033[m"
	echo -e "Where:\n\tpages_to_break_after - integer numbers separated by spaces"
	exit $1
}

if [ ! -f `which spdf` ] ; then 
	echo
	echo Dependency missing.
	echo Please install \"spdf-git\".
	echo We also recommended package \"jpdf-git\" for joining PDF files.
	echo
	exit 1
fi

n=$#			# number of parameters, including the file name
if (($n < 2)) ; then
	echo -e "\npdf_cutting (v${VERSION}) splits a given PDF file into two or more parts."
	echo -e "The original PDF file remains untouched. Cutting is done on a copy.\n"
	usemsg 1
fi
i=0
nn=0			# non-nunerical entries
while [ $i -lt $n ] ; do
	if (($1)) 2>/dev/null ; then # Is $1 numeric?
		PAGES[$i]=$1
	else
		((nn++));
		if (( nn > 1 )) ; then
			echo Too many non-numerical entries.
			echo There can be only one file name.
			usemsg 3
		fi
		f=$(basename "$1" .pdf)	 # PDF-file name to be cut
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

#echo File to cut: $f.pdf

cp "$f.pdf" tmp.pdf
f=tmp
i=0
((n--))
while [ $i -lt $n ]
do
	spdf $f.pdf ${PAGES[i]} > /dev/null 2>&1
	if [[ $? -gt 0 ]] ; then 
		echo Can\'t split after page ${PAGES[i]}
		echo Out of range.
		exit 1
	fi
	echo Cut after page ${PAGES[i]}
	mv $f\_part2.pdf pdf_$((${PAGES[i]}+1)).pdf
	# rm $f.pdf  # Not necessary. 'shred -un1' might be useful.
	mv $f\_part1.pdf $f.pdf
	j=$i
	((i++))
	while [ $i -lt $n ] && [ ${PAGES[i]} -eq ${PAGES[j]} ]
	do
		j=$i
		((i++))
	done
done
mv $f.pdf pdf_1.pdf
echo Done.
