#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/AudioRelay
install_file $PRODUCTDIR/lib/AudioRelay.png /usr/share/pixmaps/$PRODUCT.png

install_file $PRODUCTDIR/lib/audiorelay-AudioRelay.desktop /usr/share/applications/$PRODUCT.desktop
fix_desktop_file /opt/audiorelay/bin/AudioRelay $PRODUCT
fix_desktop_file /opt/audiorelay/lib/AudioRelay.png $PRODUCT

# TODO:
# https://aur.archlinux.org/packages/audiorelay

add_libs_requires
