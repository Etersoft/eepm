#!/bin/sh

WRITE=''
[ "$1" = "--write" ] && WRITE=1

for ROOTDIR in $(ls -1d etc/*) ; do
    export ROOTDIR
    e=$(../bin/distr_info -e)
    if [ -n "$WRITE" ] ; then
        echo "$e" > $ROOTDIR/etalon.txt
        continue
    fi
    le="$(cat $ROOTDIR/etalon.txt 2>/dev/null)"
    if [ "$le" = "$e" ] ; then
        printf "%23s -> %20s : %s\n" "$(basename $ROOTDIR)" "$e" "OK"
    else
        printf "%23s -> %20s : %s\n" "$(basename $ROOTDIR)" "$e" "FAIL (expect $le)"
    fi
done

