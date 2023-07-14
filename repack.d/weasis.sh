#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=weasis

PREINSTALL_PACKAGES="coreutils glib2 libalsa libatk libcairo libcairo-gobject fontconfig libfreetype libgdk-pixbuf libgio libGL libgtk+2 libgtk+3 libnsl1 libpango libX11 libXext libXi libXrender libXtst"

. $(dirname $0)/common.sh

add_bin_link_command weasis $PRODUCTDIR/bin/Weasis
add_bin_link_command Weasis $PRODUCTDIR/bin/Weasis
add_bin_link_command Dicomizer $PRODUCTDIR/bin/Dicomizer

install_file $PRODUCTDIR/lib/Weasis.png /usr/share/pixmaps/Weasis.png
install_file $PRODUCTDIR/lib/Dicomizer.png /usr/share/pixmaps/Dicomizer.png

install_file $PRODUCTDIR/lib/weasis-Weasis.desktop /usr/share/applications/weasis-Weasis.desktop
install_file $PRODUCTDIR/lib/weasis-Dicomizer.desktop /usr/share/applications/weasis-Dicomizer.desktop

# exec
fix_desktop_file "/opt/weasis/bin/Weasis"
fix_desktop_file "/opt/weasis/bin/Dicomizer"
# icons
fix_desktop_file "/opt/weasis/lib/Weasis"
fix_desktop_file "/opt/weasis/lib/Dicomizer"

cd $BUILDROOT$PRODUCTDIR/ || fatal
if epm assure patchelf ; then
    for i in lib/runtime/lib/lib*.so ; do
        a= patchelf --set-rpath '$ORIGIN:$ORIGIN/server' $i
    done
fi

#add_findreq_skiplist "$PRODUCTDIR/runtime/lib/amd64/libav*.so"

set_autoreq 'yes'
