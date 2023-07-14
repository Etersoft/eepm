#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# FIXME: missed in the package
#filter_from_requires libQt5MultimediaGstTools libQt5WaylandClient
PREINSTALL_PACKAGES="libqt5-multimedia libqt5-waylandclient fontconfig glib2 libalsa libatk libcairo libcairo-gobject libcups libdbus libdrm libEGL libexpat libfreetype libgbm libgdk-pixbuf libgio libGL libgst-plugins1.0 libgstreamer1.0 libgtk+2 libgtk+3 libkrb5 liblzma libnspr libnss libpango libpulseaudio libwayland-client libwayland-cursor libwayland-egl libX11 libxcb libxcb-render-util libxcbutil-icccm libxcbutil-image libxcbutil-keysyms libXcomposite libXdamage libXext libXfixes libxkbcommon libxkbcommon-x11 libXrandr libXrender libXtst perl-base zlib"

. $(dirname $0)/common.sh

#ln -s /lib64/libbz2.so.1 $BUILDROOT/opt/XnView/lib/libbz2.so.1.0
#subst "s|%files|%files\n/opt/XnView/lib/libbz2.so.1.0|" $SPEC

#subst '1iRequires:bzlib' $SPEC
set_autoreq "yes,noperl"

if epm assure patchelf ; then
for i in $BUILDROOT/opt/XnView/lib/{*.so.*,*.so} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done
for i in $BUILDROOT/opt/XnView/Plugins/{*.so,*.so.*} ; do
    a= patchelf --set-rpath '$ORIGIN/:$ORIGIN/../lib/' $i || continue
done
for i in $BUILDROOT/opt/XnView/lib/*/*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../' $i || continue
done
for i in $BUILDROOT/opt/XnView/XnView ; do
    a= patchelf --set-rpath '$ORIGIN/lib/' $i || continue
done
fi
