#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=zoom
PRODUCTDIR=/opt/zoom

. $(dirname $0)/common-chromium-browser.sh

# TODO: remove it after fix https://bugzilla.altlinux.org/42189
# fix broken symlink
rm -fv $BUILDROOT/usr/bin/zoom
add_bin_link_command $PRODUCT $PRODUCTDIR/ZoomLauncher

fix_chrome_sandbox $PRODUCTDIR/cef/chrome-sandbox

fix_desktop_file /usr/bin/zoom

remove_file /opt/zoom/Qt/qml/Qt/labs/lottieqt/liblottieqtplugin.so
add_libs_requires
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

