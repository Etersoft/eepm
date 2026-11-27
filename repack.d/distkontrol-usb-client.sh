#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=distkontrol-usb-client
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

pack_dir /etc/$PRODUCT

# system dir
subst "s|^%dir /usr/lib/modules-load.d/*$||" $SPEC
subst "s|^%dir \"/usr/lib/modules-load.d/*\"$||" $SPEC

# GUI client is UPX-packed (dependency autodetection does not work), the list is got with LD_DEBUG=files
if [ -f "$BUILDROOT$PRODUCTDIR/dkclt64" ] ; then
    add_unirequires libSM.so.6 libX11.so.6 libcairo.so.2 libfontconfig.so.1 libgdk-3.so.0 libgdk_pixbuf-2.0.so.0 \
        libgio-2.0.so.0 libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-3.so.0 libpango-1.0.so.0 libpangocairo-1.0.so.0 \
        libpangoft2-1.0.so.0 libstdc++.so.6 libxkbcommon.so.0
fi
