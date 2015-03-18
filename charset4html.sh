#!/bin/bash

VER=0.99 # 2015-03-18 by wm (A help msg wouldn't come amiss for ver.1.)

SET="A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
SET=${SET}" a b c d e f g h i j k l m n o p q r s t u v w x y z"
SET=${SET}" Ą Ę Ć Ł Ń Ó Ś Ż Ź ą ę ć ł ń ó ś ż ź"
SET=${SET}" 1 2 3 4 5 6 7 8 9 0"
SET=${SET}" , . ? ! ; ' \/ \" „ ”"

echo; echo Alfaber, cyfry i interpunkcja
echo " "${SET// /}; echo

SET=${SET}" + = \( ) \[ ] \{ }"
SET=${SET}" Ä Æ Ö Œ Ü ä æ ü ö œ ß ™ ® ©"
SET=${SET}" Ø ø"     # Slashed "o":  <c><s>u00f8 ø  <c><s>u00f8 Ø
SET=${SET}" ∅ ⌀ °"   # Empty sign 2205, diameter 2300, degree 00b0
SET=${SET}" Å å Å"   # 00c5  00e5  212b A with a ring; Angstrom sign
SET=${SET}" € $ ¢"
SET=${SET}" - ‐ ‑ ‒ –"   # hyphen/dash signs 2010, 2011, 2012, 2013
OUT=""

while [[ -n "$1" ]] && [ -f "$1" ]; do
	echo $1
	for c in $SET; do
		[[ ! $OUT = *${c}* ]] && \
		[[ -n $(cat "$1" | sed 's|<[^>]*>||g'|awk /$c/' {print $0}') ]] && \
		OUT=${OUT}${c}
#		echo $c $OUT
	done
#	echo ${OUT}
	shift
done
#for (( i = 0; i < ${#OUT[@]}; i++ )); do echo “${OUT[$i]}”; done
echo; echo Characters found in the files
echo -n " ";echo "$OUT" | grep -o . | sort -g |tr -d '\n'; echo

