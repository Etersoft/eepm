#!/bin/sh

__filter_by_installed_packages()
{
    local i
    local tapt="$1"

    local pkglist
    pkglist="$(mktemp)" || fatal
    remove_on_exit $pkglist
    epm --short packages | sort >$pkglist
    join -11 -21 $tapt $pkglist

    # get supported packages list and print lines with it
    #for i in $(epm query --short $(cat $tapt | cut -f1 -d" ") 2>/dev/null) ; do
    #    grep "^$i " $tapt
    #done
}

__filter_by_installed_packages test_join.txt
