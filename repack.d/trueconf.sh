#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
ORIGINPACKAGE="$4"

PRODUCT=trueconf
PRODUCTDIR=/opt/trueconf/client

. $(dirname $0)/common.sh

# follow original requires
reqs="$(epm requires "$ORIGINPACKAGE")"
[ -n "$reqs" ] && add_requires $reqs

# for old trueconf (before 8.4.0.1957)
[ -d .$PRODUCTDIR ] || PRODUCTDIR=/opt/$PRODUCT

add_bin_link_command

chmod a+x .$PRODUCTDIR/trueconf
chmod a+x .$PRODUCTDIR/trueconf-autostart

if [ -e .$PRODUCTDIR/QtWebEngineProcess ]; then
    chmod a+x .$PRODUCTDIR/QtWebEngineProcess
fi

# TODO: report the bug:
# libhwloc.so.5 => not found (we have only libhwloc.so.15)
#remove_file $PRODUCTDIR/lib/libtbbbind.so
#remove_file $PRODUCTDIR/lib/libtbbbind.so.2
# or
#filter_from_requires libhwloc.so.5

# (requires is disabled by default now)