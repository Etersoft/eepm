#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PREINSTALL_PACKAGES="libalsa libfreetype libpulseaudio libX11 libXext libXi libXrender libXtst zlib"
# needs /usr/lib64/alsa-lib/libasound_module_ctl_pulse.so
PREINSTALL_PACKAGES="$PREINSTALL_PACKAGES alsa-plugins-pulse"

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/AudioRelay
install_file $PRODUCTDIR/lib/AudioRelay.png /usr/share/pixmaps/$PRODUCT.png

install_file $PRODUCTDIR/lib/audiorelay-AudioRelay.desktop /usr/share/applications/$PRODUCT.desktop
fix_desktop_file /opt/audiorelay/bin/AudioRelay $PRODUCT
fix_desktop_file /opt/audiorelay/lib/AudioRelay.png $PRODUCT

for i in .$PRODUCTDIR/lib/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

for i in .$PRODUCTDIR/lib/runtime/lib/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN:$ORIGIN/server' $i
done

add_requires $PREINSTALL_PACKAGES

# TODO:
# https://aur.archlinux.org/packages/audiorelay
