#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=assistant

. $(dirname $0)/common.sh

# fix broken link
ln -sf /usr/lib64/libudev.so.1 $BUILDROOT$PRODUCTDIR/lib/libudev.so

install_file $PRODUCTDIR/share/icons/assistant.png /usr/share/pixmaps/$PRODUCT.png
install_file $PRODUCTDIR/scripts/assistant.desktop /usr/share/applications/$PRODUCT.desktop
fix_desktop_file /opt/assistant/scripts/assistant.sh $PRODUCT
fix_desktop_file /opt/assistant/share/icons/assistant.png $PRODUCT

add_bin_link_command $PRODUCT $PRODUCTDIR/scripts/assistant.sh

