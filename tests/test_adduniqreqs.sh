#!/bin/sh

subst()
{
    echo "$*"
}

add_unirequires()
{
    [ -n "$1" ] || return
    if [ "$(epm print info -b)" = "64" ] ; then
        local req reqs
        reqs=''
        for req in $* ; do
            reqs="$reqs $req"
            echo "$req" | grep "^lib" | grep -q -v -F "(64bit)" && reqs="$reqs"'()(64bit)'
        done
        subst "1iRequires:$reqs" $SPEC
    else
        subst "1iRequires: $*" $SPEC
    fi
}

add_unirequires "libstdc++.so.6 libX11-xcb.so.1 libX11.so.6 libXau.so.6 libxcb.so.1 libXcursor.so.1 libXdmcp.so.6 libXext.so.6 libXfixes.so.3 libXrender.so.1"
