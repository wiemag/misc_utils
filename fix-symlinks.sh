#!/bin/bash
# by w.magusiak at gmail .com
# https://www.commandlinefu.com/commands/view/8260/find-broken-symlinks
VERSION="0.1" 	# 2019-01-14
RUN=0
DST0="$(pwd)" # where to check and fix the symlinks

function usage() {
echo -e "\nUsage:\n\t\e[1m${0##*/} [-d DST] -s SRC [-r] | -h | --help\e[0m\n"
echo -e "Use flag \e[33;1m-r\e[0m to relink broken (file) symlinks."
echo -e "Recommendation:  run without \e[33;1m-r\e[0m first to see broken links.\n"
cat <<OPCJE
Options:

-r Effect the changes; Otherwise the script is run dry.
-d Directory where broken links are looked for.
   Defaults to the current one.
-s Source directory, where regular files to be linked-to are stored.
   This parameter is required.

If defined, \$WINEPREFIX path is ignored.
OPCJE
}

function wrong_exit() {
if ! [[ -d "$1" ]]; then
	echo \[!\] Path \'$1\' does not exist. Aborting...;
	exit $2;
fi
}

[[ "$1" == '--help' ]] && { usage; exit;}

while getopts "d:s:rhV" flag
do
    case "$flag" in
        d) DST0="$OPTARG"; wrong_exit "$DST0" 1 ;;
        s) SRC0="$OPTARG"; wrong_exit "$SRC0" 2 ;;
        r) RUN=1;;
        h) usage; exit;;
        V) echo -e "${0##*/} version ${VERSION}" && exit;;
    esac
done
[[ $SRC0 == '' ]] && {
	echo -e "\n\e[33;1mUse the -s parameter\e[0;m";
	usage; exit 3;
}
# Ignore .win32 directory ($WINEPREFIX)
env|grep -q WINEPREFIX || {
	WINEPREFIX='some_unlikely_path_name_somewhere_@\$\&\^32R2+3c02';
	UNSET_WP=1
}
find "$DST0" -not -path $WINEPREFIX'/*' -type l -xtype l | while read WL; do
	WP=$(readlink "$WL");
	# [[ ${WP:0:1} != '/' && ${WP:0:1} != '.' ]] && WP="./${WP}"
	# Search for file names acc.to wrong path (WP), not wrong link (WL)
	CP=$(find $SRC0 -name "${WP##*/}")
	RELPATH=$(realpath --relative-to="${WL%/*}" "$CP" 2>/dev/null) ||
	echo Regular file/Correct path not found.
	[[ $RUN -eq 0 ]] && {
		echo Wrong link = $WL;
		echo Wrong path = $WP;
		echo Correct path = $CP;
		echo Relative path = $RELPATH;
		echo '--DRY-RUN-----------';
	} || {
		ln -fs "$RELPATH" "${WL}";
	}
done
(($UNSET_WP)) && unset WINEPREFIX UNSET_WP
