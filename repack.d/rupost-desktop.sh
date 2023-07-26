#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

UNIREQUIRES="
libX11-xcb.so.1 libX11.so.6 libXcomposite.so.1 libXcursor.so.1 libXdamage.so.1 libXext.so.6 libXfixes.so.3 libXi.so.6 libXrandr.so.2 libXrender.so.1 libXtst.so.6
libasound.so.2 libatk-1.0.so.0 libcairo-gobject.so.2 libcairo.so.2 libdbus-1.so.3 libdbus-glib-1.so.2
libfontconfig.so.1 libfreetype.so.6
libgdk-3.so.0 libgdk_pixbuf-2.0.so.0
libgio-2.0.so.0 libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-3.so.0
libpango-1.0.so.0 libpangocairo-1.0.so.0
librt.so.1 libstdc++.so.6
libxcb-shm.so.0 libxcb.so.1
"

. $(dirname $0)/common.sh

rm -v ./usr/bin/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT.sh

move_to_opt

