#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
ORIGINPACKAGE="$4"

PRODUCT=trueconf
PRODUCTDIR=/opt/trueconf/client

. $(dirname $0)/common.sh

# bundled Qt5 modules not available in all branches
ignore_lib_requires libQt5Bodymovin.so.5 libQt5VirtualKeyboard.so.5 libQt5WaylandCompositor.so.5

# follow original requires, excluding the bundled ones
reqs="$(epm requires "$ORIGINPACKAGE" | grep -v 'libQt5Bodymovin\|libQt5VirtualKeyboard\|libQt5WaylandCompositor')"
[ -n "$reqs" ] && add_requires $reqs pulseaudio-daemon

# for old trueconf (before 8.4.0.1957)
[ -d .$PRODUCTDIR ] || PRODUCTDIR=/opt/$PRODUCT

add_bin_link_command

chmod a+x .$PRODUCTDIR/trueconf
chmod a+x .$PRODUCTDIR/trueconf-autostart

if [ -e .$PRODUCTDIR/QtWebEngineProcess ]; then
    chmod a+x .$PRODUCTDIR/QtWebEngineProcess
fi

if [ -e .$PRODUCTDIR/qt5/libexec/QtWebEngineProcess ]; then
    chmod a+x .$PRODUCTDIR/qt5/libexec/QtWebEngineProcess
fi


# TODO: report the bug:
# libhwloc.so.5 => not found (we have only libhwloc.so.15)
#remove_file $PRODUCTDIR/lib/libtbbbind.so
#remove_file $PRODUCTDIR/lib/libtbbbind.so.2
# or
#filter_from_requires libhwloc.so.5

# (requires is disabled by default now)
