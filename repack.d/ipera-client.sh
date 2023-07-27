#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ipera-client
PRODUCTDIR=/opt/ipera

UNIREQUIRES="binutils coreutils
libXcomposite.so.1 libXdamage.so.1 libXext.so.6 libXfixes.so.3 libXrandr.so.2 libXrender.so.1 libXtst.so.6
libasound.so.2 libdrm.so.2 libexpat.so.1 libglib-2.0.so.0 libgmodule-2.0.so.0 libgthread-2.0.so.0
libnspr4.so libnss3.so libnssutil3.so libopenal.so.1 liborc-0.4.so.0 libplc4.so libplds4.so libpulse-mainloop-glib.so.0
libpulse.so.0 libresolv.so.2 libsmime3.so
libudev.so.1
libxkbcommon-x11.so.0 libxkbcommon.so.0
libxml2.so.2 libxslt.so.1 libz.so.1"

. $(dirname $0)/common.sh

