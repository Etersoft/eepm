#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=zed
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

# fix wmclass (upstream already uses dev.zed.Zed.desktop since ~0.226)
if [ -f "$BUILDROOT/usr/share/applications/zed.desktop" ] ; then
    move_file /usr/share/applications/zed.desktop /usr/share/applications/dev.zed.Zed.desktop
fi

