#!/bin/sh

WRITE=''
[ "$1" = "--write" ] && WRITE=1

for ROOTDIR in $(ls -1d etc/*) ; do
    export ROOTDIR
    e=$(../bin/distr_info -e)
    s=$(../bin/distr_info -s)
    r=$(../bin/distr_info --repo-name)
    idstr="$e $s/$r"
    if [ -n "$WRITE" ] ; then
        echo "$idstr" > $ROOTDIR/etalon.txt
        continue
    fi
    le="$(cat $ROOTDIR/etalon.txt 2>/dev/null)"
    if [ "$le" = "$idstr" ] ; then
        printf "%23s -> %20s : %s\n" "$(basename $ROOTDIR)" "$idstr" "OK"
    else
        printf "%23s -> %20s : %s\n" "$(basename $ROOTDIR)" "$idstr" "FAIL (expect $le)"
    fi
done

