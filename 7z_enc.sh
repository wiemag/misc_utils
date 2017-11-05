#!/bin/bash
# Compresses files into a 7z file, password-protecting the file list and the contents.
VERSION='0.3'
if [[ $# -lt 1 ]] || [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
	echo -e "\nVersion $VERSION usage:\n\n\t${0##*/} File1 [File2 [File3 [...]]] OUTPUT[.7z]\n"
	echo The script adds .7z extension automatically if not present.
	echo Note that 7z does the same anyways.
	echo -e "If OUTPUT.7z exists, the script tries to add files to that archive.\n"
	echo The script does not follow symlinks.
	exit
fi
for OUTPUT; do true; done # Find the last argument.
## Another way to find the last argument
#OUTPUT=${!#}
#echo DEBUG: \$OUTPUT=$OUTPUT >&2

if [[ "${OUTPUT##*.}" == '7z' ]]; then
	N=$(( $# -1 ))	# Number of files to compress
else
	OUTPUT="${OUTPUT%.*}.7z" # Replace .ext with .7z
	N=$#	# Number of files to compress
fi
if [[ $N -eq 0 ]]; then
	echo No files to compress.
	exit
fi
# If OUTPUT.7z exists but is not a 7-zip archive, let the script continue,
# but add another .7z extension
if [[ -f "$OUTPUT" ]]; then
	if [[ $(file -b "$OUTPUT"|cut -d\  -f1) == '7-zip' ]]; then
		Q='n'
		echo -ne "\nWarning. File '$OUTPUT' exists.\nAdd file(s) to the archive?  (y/N) "
		read -t10 -n1 -s Q
		[[ ${Q,,} != 'y' ]] && { echo Copmression aborted; exit;}
		echo
	else
		OUTPUT="${OUTPUT}.7z" # Add another .7z
	fi
fi
#echo 1:1 ${@:1:1} # jeden argument od pierwszego
#echo 2:1 ${@:2:1} # jeden argument od drugiego
#echo 2   ${@:2} # wszystkie argumenty od drugiego
#echo 1:2: ${@:1:2} # dwa argumenty od pierwszego
FILES=()
#FILES=${@:1:$N} # Does not work with names cantaining spaces.
for (( i=1; i<$N+1; i++)); do
	[[ -f "${@:$i:1}" ]] || echo "${@:$i}" does not exist! Aborting.
	FILES[$i]="${@:$i:1}"
done
# -p  	# Ask for password
# -mhe  # Hide file list
7z a -p -mhe "$OUTPUT" "${FILES[@]}" && echo File \'$OUTPUT\' created
