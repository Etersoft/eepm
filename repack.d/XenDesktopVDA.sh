#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

if [ "$(epm print info -a)" = "x86_64" ] ; then
    # 32 bit
    rm -rfv $BUILDROOT/opt/Citrix/VDA/lib32
    subst "s|.*/libctxXrandrhook.so.||" $SPEC
fi

filter_from_requires AuthManagerDaemon

set_autoreq 'yes'
