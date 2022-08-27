#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=trueconf
PRODUCTDIR=/opt/trueconf

. $(dirname $0)/common.sh

add_bin_link_command

chmod a+x $BUILDROOT/opt/trueconf/trueconf
chmod a+x $BUILDROOT/opt/trueconf/trueconf-autostart

epm assure patchelf || exit
for i in lib/libboost*.so  ; do
    a= patchelf --set-rpath '$ORIGIN' $BUILDROOT$PRODUCTDIR/$i
done

for i in TrueConf ; do
    a= patchelf --set-rpath '$ORIGIN/lib' $BUILDROOT$PRODUCTDIR/$i
done
