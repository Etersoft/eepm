#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ipera-client
PRODUCTDIR=/opt/ipera

. $(dirname $0)/common.sh

LIBDIR=$(echo $BUILDROOT/opt/ipera/client/*/lib)
[ -d "$LIBDIR" ] || fatal "Can't find $LIBDIR"

epm assure patchelf || exit
cd $LIBDIR
for i in lib*.so.* gstreamer-0.10/lib*.so.*  ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

