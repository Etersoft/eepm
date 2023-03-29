#!/bin/sh

load_helper()
{
    . ../bin/$1
}

PMTYPE=apt-rpm

. ../bin/epm-sh-functions

test()
{
    [ "$(sed_escape "$1")" = "$2" ] && echo "OK: $1 -> $2" || echo "FAILED: $1 -> $(sed_escape "$1"), waited $2"
}

test "rpm [lab50] http://packages.lab50.net okular/alt/x86_64 p10" "rpm \[lab50\] http://packages\.lab50\.net okular/alt/x86_64 p10"
