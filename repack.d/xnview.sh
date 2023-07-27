#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

UNIREQUIRES="libEGL.so.1 libGL.so.1
libQt5MultimediaGstTools.so.5 libQt5WaylandClient.so.5
libX11-xcb.so.1 libX11.so.6 libXcomposite.so.1 libXext.so.6
libasound.so.2 libatk-1.0.so.0 libcairo-gobject.so.2 libcairo.so.2 libcups.so.2 libdbus-1.so.3 libdrm.so.2
libfontconfig.so.1 libfreetype.so.6 libgbm.so.1 libgcc_s.so.1 libgdk-3.so.0 libgdk-x11-2.0.so.0 libgdk_pixbuf-2.0.so.0
libgio-2.0.so.0 libglib-2.0.so.0 libgobject-2.0.so.0
libgssapi_krb5.so.2 libgstallocators-1.0.so.0 libgstapp-1.0.so.0 libgstaudio-1.0.so.0 libgstbase-1.0.so.0 libgstpbutils-1.0.so.0 libgstreamer-1.0.so.0 libgstvideo-1.0.so.0
libgthread-2.0.so.0 libgtk-3.so.0 libgtk-x11-2.0.so.0
libc.so.6 libm.so.6 librt.so.1 libdl.so.2  libstdc++.so.6
libpango-1.0.so.0 libpangocairo-1.0.so.0
libpthread.so.0 libpulse-mainloop-glib.so.0 libpulse.so.0
libwayland-client.so.0 libwayland-cursor.so.0 libwayland-egl.so.1
libxcb-glx.so.0 libxcb-icccm.so.4 libxcb-image.so.0 libxcb-keysyms.so.1 libxcb-randr.so.0 libxcb-render-util.so.0 libxcb-render.so.0 libxcb-shape.so.0 libxcb-shm.so.0 libxcb-sync.so.1 libxcb-xfixes.so.0
libxcb-xinerama.so.0 libxcb-xkb.so.1libxcb.so.1
libxkbcommon-x11.so.0 libxkbcommon.so.0
libz.so.1"

. $(dirname $0)/common.sh
