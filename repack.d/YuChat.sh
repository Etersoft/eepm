#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yuchat
PRODUCTDIR=/opt/YuChat

. $(dirname $0)/common.sh

# the original bash wrapper adds --no-sandbox (or an empty argument),
# we use SUID chrome-sandbox instead (see add_electron_deps)
remove_file $PRODUCTDIR/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT.bin

fix_desktop_file

# used only by the original %post (Ubuntu AppArmor)
remove_file $PRODUCTDIR/resources/apparmor-profile

add_electron_deps
