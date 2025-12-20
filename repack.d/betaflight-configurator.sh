#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=betaflight-configurator
PRODUCTDIR=/opt/betaflight/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command

install_file $PRODUCTDIR/icon/bf_icon_128.png /usr/share/pixmaps/$PRODUCT.png
install_file $PRODUCTDIR/$PRODUCT.desktop /usr/share/applications/$PRODUCT.desktop

fix_desktop_file
fix_desktop_file "$PRODUCTDIR/icon/bf_icon_128.png" "$PRODUCT"

# Set executable permissions for executable files and libraries
find $BUILDROOT/$PRODUCTDIR -type f \( -name "*.so" -o -name "betaflight-configurator" -o -name "chrome_crashpad_handler" \) -exec chmod a+x {} \;

