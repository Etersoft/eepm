#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=code
PRODUCTCUR=vscode
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt

add_electron_deps

fix_desktop_file /usr/share/code/code

rm $BUILDROOT/usr/bin/code
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/code
add_bin_link_command $PRODUCTCUR $PRODUCTDIR/bin/code

subst "s|^Group:.*|Group: Development/Tools|" $SPEC
