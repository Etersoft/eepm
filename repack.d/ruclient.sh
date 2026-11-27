#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ruclient

. $(dirname $0)/common.sh

VERSION="$(grep '^Version:' $SPEC | sed -e 's|^Version:[[:space:]]*||')"

# the vendor's postinstall enables and starts ruclient.service, epm play suggests to do it

# /lib is not usrmerged on all systems
move_file /lib/systemd/system/$PRODUCT.service /usr/lib/systemd/system/$PRODUCT.service

# system dir
subst "s|^%dir /usr/lib/modules-load.d/*$||" $SPEC
subst "s|^%dir \"/usr/lib/modules-load.d/*\"$||" $SPEC

# the GUI client of the same version
GUIURL="https://archive.nio-electronics.ru/client/Linux/$VERSION/GUI/rhclt64"
if epm tool eget -O "$BUILDROOT/usr/bin/rhclt64" "$GUIURL" ; then
    chmod 0755 "$BUILDROOT/usr/bin/rhclt64"
    pack_file /usr/bin/rhclt64
    # UPX-packed (dependency autodetection does not work), the list is got with LD_DEBUG=files
    add_unirequires libSM.so.6 libX11.so.6 libcairo.so.2 libcairo-gobject.so.2 libfontconfig.so.1 libgdk-3.so.0 libgdk_pixbuf-2.0.so.0 \
        libgio-2.0.so.0 libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-3.so.0 libpango-1.0.so.0 libpangocairo-1.0.so.0 \
        libpangoft2-1.0.so.0 libstdc++.so.6 libxkbcommon.so.0
else
    rm -f "$BUILDROOT/usr/bin/rhclt64"
    warning "Can't download the GUI client from $GUIURL, skipping"
fi
