#!/bin/sh

LIST="bin/epm-* bin/distr_info bin/serv-* bin/tools* play.d/*.sh prescription.d/*.sh repack.d/*.sh"

if [ "$1" = "--detail" ] ; then
    if [ -n "$2" ] ; then
        LIST="$2"
        bash --rpm-requires $LIST | sort -u | grep "executable"
        exit
    fi
    for i in $LIST  ; do
        echo
        echo "==== $i:"
        /usr/lib/rpm/shell.req $i | grep -v "coreutils"
    done
    exit 0
fi

for i in $LIST  ; do
    echo
    echo "==== $i:"
    /usr/lib/rpm/shell.req $i | grep -v "coreutils" | grep -v "^eepm$"
done | tee ./check_eepm-detail.log

#/usr/lib/rpm/shell.req $LIST | sort -u | tee ./check_eepm.log
cat ./check_eepm-detail.log | grep -v "^$" | grep -v "^===" | sort -u | tee ./check_eepm.log
git diff ./check_eepm.log
