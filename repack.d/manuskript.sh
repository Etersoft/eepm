#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=manuskript

. $(dirname $0)/common.sh

move_to_opt


subst "s|/usr/share/manuskript/|$PRODUCTDIR/|" usr/bin/manuskript

fix_desktop_file /usr/bin/manuskript
fix_desktop_file Icon=/usr/share/manuskript/icons/Manuskript/icon-512px.png $PRODUCT

install_file /usr/share/manuskript/icons/Manuskript/icon-512px.png /usr/share/icons/hicolor/256x256/apps/$PRODUCT.png

add_unirequires python3(enchant) python3(lxml) python3(markdown)
add_unirequires python3(qt5) python3(qt5-webkit)
add_unirequires libQt5Svg.so.5

add_libs_requires
