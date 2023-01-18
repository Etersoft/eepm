#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=trueconf
PRODUCTDIR=/opt/trueconf

. $(dirname $0)/common.sh

add_bin_link_command

chmod a+x $BUILDROOT/opt/trueconf/trueconf
chmod a+x $BUILDROOT/opt/trueconf/trueconf-autostart

epm assure patchelf || exit
for i in lib/lib*.so  ; do
    a= patchelf --set-rpath '$ORIGIN' $BUILDROOT$PRODUCTDIR/$i
done

for i in TrueConf ; do
    a= patchelf --set-rpath '$ORIGIN/lib' $BUILDROOT$PRODUCTDIR/$i
done

# libhwloc.so.5 => not found (we have only libhwloc.so.15)
remove_file $PRODUCTDIR/lib/libtbbbind.so
remove_file $PRODUCTDIR/lib/libtbbbind.so.2

epm install --skip-installed pulseaudio libalsa libcrypto1.1 libcurl libdbus libGL libicu69 libidn libgs libprotobuf27 libarchive13  libXScrnSaver libspeex libspeexdsp libudev1 libv4l libX11 libxcb libXrandr liblame libatomic1 coreutils
epm install --skip-installed libqt5-core libqt5-dbus libqt5-gui libqt5-multimedia libqt5-network libqt5-opengl libqt5-sql libqt5-svg libqt5-webkit libqt5-webkitwidgets libqt5-widgets libqt5-webengine libqt5-concurrent qt5-graphicaleffects qt5-imageformats qt5-qtquickcontrols
