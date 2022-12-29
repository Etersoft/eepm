#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=librewolf

. $(dirname $0)/common.sh

subst '1iAutoReq:yes,noshell,nomonolib,nomono,nopython' $SPEC
subst '1iAutoProv:no' $SPEC

move_to_opt
subst "s|/usr/share/$PRODUCT/$PRODUCT|$PRODUCT|" $BUILDROOT/usr/share/applications/start-$PRODUCT.desktop

cleanup

rm -f $BUILDROOT/usr/bin/librewolf
add_bin_link_command

epm assure patchelf || exit
for i in $BUILDROOT/$PRODUCTDIR/{lib*.so,plugin-container} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

for i in $BUILDROOT/$PRODUCTDIR/gmp-clearkey/0.1/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../' $i || continue
done
