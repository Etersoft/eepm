#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ipera-client
PRODUCTDIR=/opt/ipera

PREINSTALL_PACKAGES="libQt5Pdf.so.5()(64bit)"

. $(dirname $0)/common.sh

LIBDIR=$(echo $BUILDROOT/opt/ipera/client/*/lib)
[ -d "$LIBDIR" ] || exit

if epm assure patchelf ; then
cd $LIBDIR
for i in lib*.so.* gstreamer-0.10/lib*.so.*  ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done
fi

#for i in ../bin/qml/QtQuick/Particles.2/libparticlesplugin.so ; do
#    a= patchelf --set-rpath "$LIBDIR" $i
#done

filter_from_requires "libldap_r-2.4.so.2(OPENLDAP_2.*)(64bit)" "liblber-2.4.so.2(OPENLDAP_2.*)(64bit)" "ld-linux-.*(GLIBC_PRIVATE)"
# ignore embedded libs
filter_from_requires libQt5 libav libcrypto.so libdbus-1.so libicu liblibraw.so libssl.so libswresample libswscale libva libvdpau
filter_from_requires libgst libuv

set_autoreq 'yes'
