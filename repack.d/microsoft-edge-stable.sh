#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=microsoft-edge
PRODUCTCUR=microsoft-edge-stable
PRODUCTDIR=/opt/microsoft/msedge


. $(dirname $0)/common-chromium-browser.sh

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps

#if ! grep -q '^"/usr/bin/microsoft-edge"' $SPEC ; then
#    subst 's|\(.*/usr/bin/microsoft-edge-stable.*\)|"/usr/bin/microsoft-edge"\n\1|' $SPEC
#fi

# fix wrong interpreter
epm assure patchelf || exit
for i in $BUILDROOT$PRODUCTDIR/libmip_*.so ; do
    [ "$(a= patchelf --print-interpreter $i)" = "/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2" ] && a= patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 $i
done

