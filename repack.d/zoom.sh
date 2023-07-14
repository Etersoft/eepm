#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=zoom
PRODUCTDIR=/opt/zoom

#PREINSTALL_PACKAGES="glib2 libalsa libatk libat-spi2-core libcairo libcairo-gobject libcups libdbus libdrm libEGL libexpat libgbm libgdk-pixbuf libgio libGL libgomp1 libgtk+3 libkrb5 libnspr libnss libpango libpulseaudio libwayland-client libwayland-cursor libwayland-egl libX11 libxcb libxcb-render-util libxcbutil-icccm libxcbutil-image libxcbutil-keysyms libXcomposite libXdamage libXext libXfixes libxkbcommon libxkbcommon-x11 libXrandr libXtst zlib"
UNIREQUIRES="libEGL.so.1 libGL.so.1 libX11-xcb.so.1 libX11.so.6 libXcomposite.so.1 libXdamage.so.1 libXext.so.6 libXfixes.so.3 libXrandr.so.2 libXtst.so.6 libasound.so.2
libatk-1.0.so.0 libatk-bridge-2.0.so.0 libatspi.so.0 libcairo-gobject.so.2 libcairo.so.2 libcups.so.2 libdbus-1.so.3
libdrm.so.2 libexpat.so.1 libfontconfig.so.1 libfreetype.so.6 libgbm.so.1
libgdk-3.so.0 libgdk_pixbuf-2.0.so.0 libgio-2.0.so.0 libglib-2.0.so.0 libgmodule-2.0.so.0 libgobject-2.0.so.0 libgomp.so.1 libgssapi_krb5.so.2
libgthread-2.0.so.0 libgtk-3.so.0 libnspr4.so libnss3.so libnssutil3.so libpango-1.0.so.0 libpangocairo-1.0.so.0 libsmime3.so
libwayland-client.so.0 libwayland-cursor.so.0 libwayland-egl.so.1
libxcb-glx.so.0 libxcb-icccm.so.4 libxcb-image.so.0 libxcb-keysyms.so.1 libxcb-randr.so.0 libxcb-render-util.so.0 libxcb-render.so.0 libxcb-shape.so.0 libxcb-shm.so.0 libxcb-sync.so.1
libxcb-xfixes.so.0 libxcb-xinerama.so.0 libxcb-xkb.so.1 libxcb-xtest.so.0 libxcb.so.1 libxkbcommon-x11.so.0 libxkbcommon.so.0 libz.so.1"

. $(dirname $0)/common-chromium-browser.sh

# TODO: remove it after fix https://bugzilla.altlinux.org/42189
# fix broken symlink
rm -fv $BUILDROOT/usr/bin/zoom
add_bin_link_command $PRODUCT $PRODUCTDIR/ZoomLauncher

fix_chrome_sandbox $PRODUCTDIR/cef/chrome-sandbox

fix_desktop_file /usr/bin/zoom

# autoreq is disabled: don't patch elf due requires
exit

subst '1i%filter_from_requires /^mesa-dri-drivers(x86-32)/d' $SPEC

# ignore embedded libs requires
for i in libQt5 libav libswresample libfdkaac libmpg123 libquazip libturbojpeg libicu libOpenCL ; do
    subst "1i%filter_from_requires /^$i.*/d" $SPEC
done

if epm assure patchelf ; then

for i in $BUILDROOT/opt/zoom/lib*.so.* $BUILDROOT/opt/zoom/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN:$ORIGIN/Qt/lib' $i || continue
done

for i in $BUILDROOT/opt/zoom/Qt/lib/*.so.* ; do
    a= patchelf --set-rpath '$ORIGIN:$ORIGIN/../../' $i || continue
done

for i in $BUILDROOT/opt/zoom/Qt/plugins/*/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../lib' $i || continue
done

for i in $BUILDROOT/opt/zoom/Qt/qml/QtQuick/*/lib*.so.* $BUILDROOT/opt/zoom/Qt/qml/QtQuick/XmlListModel/lib* $BUILDROOT/opt/zoom/Qt/qml/QtQml/RemoteObjects/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../../lib' $i || continue
done

for i in $BUILDROOT/opt/zoom/Qt/qml/Qt/labs/*/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../../../lib' $i
done

#for i in $BUILDROOT/opt/zoom/cef/libcef.so ; do
#    a= patchelf --set-rpath '$ORIGIN/../' $i || continue
#done

for i in $BUILDROOT/opt/zoom/{zoom,zopen} ; do
    a= patchelf --set-rpath '$ORIGIN:$ORIGIN/Qt/lib:$ORIGIN/cef' $i
done

fi

# missed Qt deps
remove_file /opt/zoom/Qt/qml/QtQuick/XmlListModel/libqmlxmllistmodelplugin.so
remove_file /opt/zoom/Qt/qml/QtQuick/Scene2D/libqtquickscene2dplugin.so
remove_file /opt/zoom/Qt/qml/QtQuick/Scene3D/libqtquickscene3dplugin.so

echo "Fix for library libQt5Multimedia.so.5 not found"
remove_file /opt/zoom/Qt/plugins/audio/libqtaudio_alsa.so
remove_file /opt/zoom/Qt/plugins/audio/libqtmedia_pulse.so

# library libQt5RemoteObjects.so.5 not found
remove_file /opt/zoom/Qt/qml/QtQml/RemoteObjects/libqtqmlremoteobjects.so
# library libQt5Sql.so.5 not found
remove_file /opt/zoom/Qt/qml/QtQuick/LocalStorage/libqmllocalstorageplugin.so
# library libQt5QuickParticles.so.5 not found
remove_file /opt/zoom/Qt/qml/QtQuick/Particles.2/libparticlesplugin.so


echo "Fix for /opt/zoom/Qt/qml/Qt/labs/lottieqt/liblottieqtplugin.so: library libQt5Bodymovin.so.5 not found"
# qt5-qtlottie
remove_file /opt/zoom/Qt/qml/Qt/labs/lottieqt/liblottieqtplugin.so

# library libQt5EglFSDeviceIntegration.so.5 not found
remove_file /opt/zoom/Qt/plugins/platforms/libqeglfs.so
remove_dir /opt/zoom/Qt/plugins/egldeviceintegrations

