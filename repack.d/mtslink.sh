#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=mtslink
PRODUCTDIR=/opt/LinkChats

. $(dirname $0)/common.sh

add_conflicts mts-link-desktop

add_bin_link_command
fix_desktop_file
install_file $PRODUCTDIR/resources/src/main/assets/icons/icon.png /usr/share/pixmaps/$PRODUCT.png
add_electron_deps
