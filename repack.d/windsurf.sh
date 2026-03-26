#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=windsurf
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt

# libmsalruntime.so in microsoft-authentication extension links against libwebkit2gtk-4.1
ignore_lib_requires libwebkit2gtk-4.1.so.0

add_electron_deps

# fix paths in desktop file
fix_desktop_file /usr/share/$PRODUCT/$PRODUCT
fix_desktop_file /usr/share/$PRODUCT/ $PRODUCTDIR/

[ -e $BUILDROOT/usr/bin/$PRODUCT ] && rm $BUILDROOT/usr/bin/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

subst "s|^Group:.*|Group: Development/Tools|" $SPEC
