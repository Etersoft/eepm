#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=librewolf

PREINSTALL_PACKAGES="fontconfig glib2 libalsa libatk libcairo libcairo-gobject libdbus libdbus-glib libfreetype libgdk-pixbuf libgio libgtk+3 libharfbuzz libpango libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst"


. $(dirname $0)/common.sh

set_autoreq 'yes,noshell,nomonolib,nomono,nopython'

move_to_opt
fix_desktop_file "/usr/share/$PRODUCT/$PRODUCT"

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
