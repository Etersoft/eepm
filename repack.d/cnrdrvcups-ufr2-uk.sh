#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_requires "glib2 libatk libcairo libcairo-gobject libcups libgdk-pixbuf libgio libgtk+3 libpango libxml2 libjbig"

# fix hang up when can't find libjbig.so libjbig.so.2.1 libjbig.so.2.0 libjbig.so.0
# source code: linux-UFRII-drv-v570-m17n/Sources/cnrdrvcups-lb-5.70-1.11.tar.xz/utar://cnrdrvcups-common-5.70/cnjbig/cnjbig.c
if [ -f /usr/lib64/libjbig.so.1.6 ] ; then
    subst 's|libjbig.so.2.0|libjbig.so.1.6|' $BUILDROOT/usr/bin/cnjbigufr2
fi

