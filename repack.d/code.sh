#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=code
PRODUCTCUR=vscode
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt

# libmsalruntime.so in microsoft-authentication extension links against libwebkit2gtk-4.1
# which is not available on older distros (c10f2, etc.)
ignore_lib_requires libwebkit2gtk-4.1.so.0

add_electron_deps

fix_desktop_file /usr/share/code/code
# TODO:

rm $BUILDROOT/usr/bin/code
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/code
add_bin_link_command $PRODUCTCUR $PRODUCT

subst "s|^Group:.*|Group: Development/Tools|" $SPEC
