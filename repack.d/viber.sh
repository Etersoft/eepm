#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Viber
PRODUCTCUR=viber
PRODUCTDIR=/opt/viber

. $(dirname $0)/common.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

subst '1i%filter_from_requires /^libtiff.so.5(LIBTIFF_.*/d' $SPEC

subst "s|$PRODUCTDIR/$PRODUCT|$PRODUCTCUR|" $BUILDROOT/usr/share/applications/viber.desktop

epm install --skip-installed glib2 gst-plugins-bad1.0 libalsa libbrotlidec libcups libdbus libdrm libEGL libexpat libfreetype libGL libGLX libgomp1 libgst-plugins1.0 libgstreamer1.0 libharfbuzz libICE libkrb5 liblcms2 libmng libmtdev libnspr libnss libOpenGL libopus libSM libsnappy libtiff5 libts0 libudev1 libwayland-client libwayland-cursor libwayland-egl libwayland-server libwebp7 libX11 libxcb libxcb-render-util libxcbutil-icccm libxcbutil-image libxcbutil-keysyms libXext libXfixes libxkbcommon libxkbcommon-x11 libxkbfile libxml2 libXrandr libXScrnSaver libxshmfence libxslt libXtst libzstd zlib
# libfontconfig1 
# seamonkey thunderbird 