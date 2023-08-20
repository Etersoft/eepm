#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
ORIGINPACKAGE="$4"

PRODUCT=trueconf
PRODUCTDIR=/opt/trueconf

. $(dirname $0)/common.sh

# follow original requires
reqs="$(epm requires "$ORIGINPACKAGE")"
[ -n "$reqs" ] && add_requires $reqs

add_bin_link_command

chmod a+x $BUILDROOT/opt/trueconf/trueconf
chmod a+x $BUILDROOT/opt/trueconf/trueconf-autostart

# TODO: report the bug:
# libhwloc.so.5 => not found (we have only libhwloc.so.15)
remove_file $PRODUCTDIR/lib/libtbbbind.so
remove_file $PRODUCTDIR/lib/libtbbbind.so.2

exit

if epm assure patchelf ; then
for i in lib/lib*.so  ; do
    a= patchelf --set-rpath '$ORIGIN' $BUILDROOT$PRODUCTDIR/$i
done

for i in TrueConf ; do
    a= patchelf --set-rpath '$ORIGIN/lib' $BUILDROOT$PRODUCTDIR/$i
done
fi

