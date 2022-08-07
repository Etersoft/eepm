#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

ln -s /lib64/libbz2.so.1 $BUILDROOT/opt/XnView/lib/libbz2.so.1.0
subst "s|%files|%files\n/opt/XnView/lib/libbz2.so.1.0|" $SPEC

#subst '1Requires:bzlib' $SPEC
subst '1iAutoReq:yes,noperl' $SPEC
subst '1iAutoProv:no' $SPEC

# ignore embedded libs
filter_from_requires libQt5 libav libcrypto.so libdbus-1.so libicu liblibraw.so libssl.so libswresample libswscale libva libvdpau

# ignore embedded libs for Plugins
filter_from_requires libHalf.so libIex libIlmThread libwebp

epm install --skip-installed bzlib fontconfig libalsa libcairo libcups libdrm libfreetype /usr/bin/perl zlib libXv glib2 libatk libcairo-gobject libEGL libgdk-pixbuf libgio libGL libgst-plugins1.0 libgstreamer1.0 libgtk+2 libgtk+3 libpango libpulseaudio libsqlite3 libX11 libxcb libxcb-render-util libXcomposite libXext libXfixes libxkbcommon libxkbcommon-x11 libXrender

