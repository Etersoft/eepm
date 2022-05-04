#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=zoom
PRODUCTDIR=/opt/zoom

. $(dirname $0)/common-chromium-browser.sh

# TODO: s/freetype/libfreetype/
# see https://bugzilla.altlinux.org/show_bug.cgi?id=38892

if [ ! -f /lib64/ld-linux-x86-64.so.2 ] ; then
    # TODO: use patchelf
    # drop x86_64 req from 32 bit binary
    sed -E -i -e "s@/lib64/ld-linux-x86-64.so.2@/lib/ld-linux.so.2\x0________@" $BUILDROOT/opt/zoom/libQt5Core.so.*
fi

# TODO: add all subdirs
subst 's|%files|%files\n%dir /opt/zoom|' $SPEC

# TODO: remove it after fix https://bugzilla.altlinux.org/42189
# fix broken symlink
rm -fv $BUILDROOT/usr/bin/zoom
ln -sv /opt/zoom/ZoomLauncher $BUILDROOT/usr/bin/zoom

subst '1i%filter_from_requires /^mesa-dri-drivers(x86-32)/d' $SPEC

# ignore embedded libs
for i in libQt5 libav libfdkaac libmpg123 libquazip libturbojpeg libicu ; do
    subst "1i%filter_from_requires /^$i.*/d" $SPEC
done

epm assure patchelf || exit
for i in $BUILDROOT/opt/zoom/{libicui18n.so,libicui18n.so.*,libicuuc.so,libicuuc.so.*} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

for i in $BUILDROOT/opt/zoom/{zoom,zopen} ; do
    a= patchelf --set-rpath '$ORIGIN/':"$PRODUCTDIR/cef" $i
done

if [ -d $BUILDROOT/opt/zoom/QtQuick/Scene2D ] ; then
    # qt5-3d libqt5-3dquickscene2d
    remove_file /opt/zoom/QtQuick/Scene2D/libqtquickscene2dplugin.so
    remove_file /opt/zoom/QtQuick/Scene3D/libqtquickscene3dplugin.so
fi

for i in $BUILDROOT/opt/zoom/xcbglintegrations/libqxcb-*-integration.so ; do
    a= patchelf --set-rpath "$PRODUCTDIR" $i
done

install_deps

epm --skip-installed install libxkbcommon-x11 libxcbutil-image libxcbutil-keysyms

fix_chrome_sandbox $PRODUCTDIR/cef/chrome-sandbox
