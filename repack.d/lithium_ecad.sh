#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt "/opt/lithium*" || fatal "can't move to $PRODUCTDIR"

add_bin_link_command $PRODUCT $PRODUCTDIR/launcher.sh

# missed with other soname
#ln -s /usr/lib64/libjasper.so.* bin/libjasper.so.1
#pack_file $PRODUCTDIR/bin/libjasper.so.1
ignore_lib_requires libjasper.so.1

install_file $PRODUCTDIR/lithium-ecad.desktop /usr/share/applications/$PRODUCT.desktop
fix_desktop_file "/opt/lithium_ecad-.*/launcher.sh"
fix_desktop_file "/opt/lithium_ecad-.*/lithium-ecad.png"

install_file $PRODUCTDIR/lithium-ecad.png /usr/share/pixmaps/$PRODUCT.png

add_libs_requires
