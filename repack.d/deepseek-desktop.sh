#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

# FIXME: unpacked??
PRODUCTDIR=/opt/deepseek-desktop/unpacked

. $(dirname $0)/common.sh

add_electron_deps

add_bin_link_command $PRODUCT

install_file /opt/$PRODUCT/meta/gui/icon.png /usr/share/pixmaps/$PRODUCT.png

fix_desktop_file /opt/$PRODUCT/unpacked/$PRODUCT

