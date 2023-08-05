#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTCUR=dbeaver

. $(dirname $0)/common.sh

move_to_opt
rm usr/bin/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCTCUR
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_desktop_file "/usr/share/dbeaver-ce/dbeaver"
fix_desktop_file "/usr/share/dbeaver-ce/dbeaver.png"
fix_desktop_file "/usr/share/dbeaver-ce/" "$PRODUCTDIR/"

add_requires java-openjdk
