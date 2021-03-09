#!/bin/sh

if [ "$1" = "--detail" ] ; then
    for i in bin/epm-* ; do
        echo
        echo "==== $i:"
        /usr/lib/rpm/shell.req $i
    done
    exit 0
fi

/usr/lib/rpm/shell.req bin/epm-* | sort -u | tee ./check_eepm.log
git diff ./check_eepm.log
