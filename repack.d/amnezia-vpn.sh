#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=AmneziaVPN
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_conflicts amnezia-vpn-client amnezia-vpn-service

# replaces post_install.sh from the original installer
move_file $PRODUCTDIR/$PRODUCT.service /usr/lib/systemd/system/$PRODUCT.service
move_file $PRODUCTDIR/$PRODUCT.desktop /usr/share/applications/$PRODUCT.desktop
move_file $PRODUCTDIR/$PRODUCT.png /usr/share/pixmaps/$PRODUCT.png
subst "s|^Icon=.*|Icon=$PRODUCT|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT
add_bin_link_command amnezia-vpn $PRODUCTDIR/bin/$PRODUCT

add_libs_requires
