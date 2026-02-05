#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# conflicts with MAX from AppImage
add_conflicts MAX

move_to_opt

fix_desktop_file /usr/share/max/bin/max

add_bin_link_command $PRODUCT /opt/$PRODUCT/bin/$PRODUCT
