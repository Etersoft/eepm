#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=sublime-text
PRODUCTCUR=subl
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

for res in 128x128 16x16 256x256 32x32 48x48; do
    install_file .$PRODUCTDIR/Icon/${res}/sublime-text.png /usr/share/icons/hicolor/${res}/apps/sublime-text.png
done

add_bin_link_command $PRODUCT $PRODUCTDIR/sublime_text
add_bin_link_command $PRODUCTCUR $PRODUCT

install_file .$PRODUCTDIR/sublime_text.desktop /usr/share/applications/$PRODUCT.desktop
fix_desktop_file /opt/sublime_text/sublime_text $PRODUCT

add_libs_requires
