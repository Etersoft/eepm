#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=librewolf

. $(dirname $0)/common.sh

move_to_opt
fix_desktop_file "/usr/share/$PRODUCT/$PRODUCT"

add_libs_requires

rm -f $BUILDROOT/usr/bin/librewolf
add_bin_link_command

if epm assure patchelf ; then
for i in $BUILDROOT/$PRODUCTDIR/{lib*.so,plugin-container} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

for i in $BUILDROOT/$PRODUCTDIR/gmp-clearkey/0.1/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../' $i || continue
done
fi
