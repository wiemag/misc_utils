#!/bin/bash -
# Removes meta data form PDFs
[[ $(which qpdf 2>/dev/null) ]] || { echo Missing dependency: qpdf; exit;}
set -o nounset      # Treat unset variables as an error
INPUT="${1-}"
[[ -f "$INPUT" ]] || { echo -e "\n${0##*/} <input.pdf> [<output>.pdf]"; exit;}
OUTPUT="${2-${INPUT%.pdf}_meta.pdf}"
qpdf -empty -pages "$INPUT" 1-z -- "$OUTPUT"
