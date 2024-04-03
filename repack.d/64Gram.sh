#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=64Gram
PRODUCTCUR=64gram
PKGNAME=$(basename $0 .sh)
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

echo "$PRODUCTDIR/$PRODUCT" | create_file /usr/share/64Gram/externalupdater.d/telegram-desktop.conf

# TODO: tg.protocol
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=telegram-desktop-bin

add_libs_requires