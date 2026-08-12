#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=weasis

. $(dirname $0)/common.sh

# Upstream deb contains Python scripts whose auto-req output includes raw Debian
# control tokens (Depends:/Suggests:), which break rpm spec generation.
stop_libs_requires
add_unirequires libX11.so.6 libXext.so.6 libXi.so.6 libXrender.so.1 libXtst.so.6 libasound.so.2

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
