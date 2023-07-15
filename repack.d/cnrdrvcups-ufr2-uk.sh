#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

UNIREQUIRES="libglib-2.0.so.0 libgmodule-2.0.so.0 libgobject-2.0.so.0 libgthread-2.0.so.0 libatk-1.0.so.0 libcairo.so.2 libcairo-gobject.so.2
libcups.so.2 libcupsimage.so.2 libgdk_pixbuf-2.0.so.0 libgio-2.0.so.0 libgdk-3.so.0 libgtk-3.so.0
libpango-1.0.so.0 libpangocairo-1.0.so.0 libpangoft2-1.0.so.0 libpangoxft-1.0.so.0 libxml2.so.2 libjbig.so.1.6"

. $(dirname $0)/common.sh

# fix hang up when can't find libjbig.so libjbig.so.2.1 libjbig.so.2.0 libjbig.so.0
# source code: linux-UFRII-drv-v570-m17n/Sources/cnrdrvcups-lb-5.70-1.11.tar.xz/utar://cnrdrvcups-common-5.70/cnjbig/cnjbig.c
if [ -f /usr/lib64/libjbig.so.1.6 ] ; then
    subst 's|libjbig.so.2.0|libjbig.so.1.6|' $BUILDROOT/usr/bin/cnjbigufr2
fi

