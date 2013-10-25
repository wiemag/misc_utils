#!/bin/bash
# By wm/dif 2013-03-26
# Dependency: gpg/gpg2
# v0.2: 2013-10-26
PL=$([[ $LANG == "pl_PL.utf8" ]] && echo 1 || echo 0)
if [[ -z $(which gpg 2>/dev/null) ]]; then
	((PL)) && echo Brakująca zależność:  gpg || echo Missing dependency:  gpg
	exit 1
fi
VERSION=0.2
LISTA=$(echo $(gpg -K|grep uid|cut -d\< -f2|cut -d\> -f1))
USER=$(echo $LISTA | cut -d\  -f1)
if ((PL)); then
	USAGE="Polecenie:\n\t\e[1mpodpiszto [-u PODPISUJĄCY] ZBIÓR_DO_PODPISANIA"
	MESSAGE="\n$USAGE\e[0m\n\nLista dostępnych PODPISUJĄCYCH:\n  $LISTA"
	MESSAGE=$MESSAGE"\n\nDomyślny PODPISUJĄCY:  $USER"
else
	USAGE="Command:\n\t\e[1msignit [-u SIGNING_USER] FILE_TO_SIGN"
	MESSAGE="\n$USAGE\e[0m\n\nAvailable users:\n  $LISTA"
	MESSAGE=$MESSAGE"\n\nDefault user:  $USER"
fi

while getopts u:hv OPT; do
    case "$OPT" in
        h) echo -e "$MESSAGE"; exit;;
	    u) USER=$OPTARG; 
	    	((  $(gpg -K|grep $USER|wc -l) )) || { 
				((PL)) && echo "Brak kucza  GPG dla użytkownika ${USER}." || 
					echo "No GPG key for user ${USER}."; 
				exit 2;
			};;
		v) ((PL)) && echo Wersja $VERSION || echo Version $VERSION ; exit;;
	   \?) # getopts issues an error message
           echo -e "$MESSAGE"; exit;;
	esac
done
# Parse command line options.
shift $(expr $OPTIND - 1)
FILE=$@
if [ -z "$FILE" ]; then
	echo -e "$MESSAGE \e[32;1m\n"
    ((PL)) && echo -n "Brak ZBIORU_DO_PODPISANIA" || echo -n "No FILE_TO_SIGN"
    echo -e "\e[0m\n"
	exit 1
fi
if [ -a "$FILE" ]; then
	((PL)) && echo Wykonuję: || echo Executing:
	echo -e "\tgpg -ba -u $USER $FILE"
	gpg -ba -u $USER "$FILE"
else
	((PL)) && echo Błąd. Zbiór \'$FILE\' nie istnieje. || 
		echo Error: File \'$FILE\' does not exist.
fi
