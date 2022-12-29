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

rm -f $BUILDROOT/usr/bin/librewolf
add_bin_link_command

epm assure patchelf || exit
for i in $BUILDROOT/$PRODUCTDIR/{lib*.so,plugin-container} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

for i in $BUILDROOT/$PRODUCTDIR/gmp-clearkey/0.1/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../' $i || continue
done

epm --skip-installed install fontconfig glib2 libalsa libatk libcairo libcairo-gobject libdbus libdbus-glib libfreetype libgdk-pixbuf libgio libgtk+3 libharfbuzz libpango libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst
