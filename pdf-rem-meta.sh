#!/bin/bash - 
# Removes meta data form PDFs
[[ $(which pdftk 2>/dev/null) ]] || { echo Missing dependency: pdftk; exit;}
set -o nounset                              # Treat unset variables as an error
INPUT="${1-}"
[[ -f "$INPUT" ]] || { echo -e "\n${0##*/} <input.pdf> [<output>.pdf]"; exit;}
OUTPUT="${2-${INPUT%.pdf}_meta.pdf}"
pdftk "$INPUT" dump_data_utf8| \
	sed -n '1,/NumberOfPages:/'p| \
	awk '/Info/' | \
	sed 's/InfoValue: .*/InfoValue:/g' > "/tmp/${USER}-${INPUT}_meta.txt"
pdftk "$INPUT" update_info_utf8 "/tmp/${USER}-${INPUT}_meta.txt" \
	output "$OUTPUT"
rm "/tmp/${USER}-${INPUT}_meta.txt"
