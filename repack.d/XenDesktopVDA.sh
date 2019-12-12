#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

if [ "$($DISTRVENDOR -a)" = "x86_64" ] ; then
    # 32 bit
    rm -rfv $BUILDROOT/opt/Citrix/VDA/lib32
    subst "s|.*/libctxXrandrhook.so.||" $SPEC
fi

#REQUIRES=""
subst "s|^\(Name: .*\)$|%filter_from_requires /AuthManagerDaemon/d\n\1|g" $SPEC

