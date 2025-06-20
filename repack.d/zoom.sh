#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

fix_chrome_sandbox $PRODUCTDIR/cef/chrome-sandbox

fix_desktop_file /usr/bin/zoom

# https://bugzilla.altlinux.org/47427
remove_file /opt/zoom/Qt/qml/Qt/labs/lottieqt/liblottieqtplugin.so

remove_file /opt/zoom/Qt/qml/QtQuick/Scene3D/libqtquickscene3dplugin.so
remove_file /opt/zoom/Qt/qml/QtQuick/Scene2D/libqtquickscene2dplugin.so
remove_file /opt/zoom/Qt/plugins/platforms/libqeglfs.so
remove_file /opt/zoom/Qt/plugins/egldeviceintegrations/libqeglfs-*.so
# bug
remove_file /opt/zoom/Qt/plugins/egldeviceintegrations/libqeglfs-kms-egldevice-integration.so
remove_file /opt/zoom/Qt/plugins/egldeviceintegrations/libqeglfs-x11-integration.so
remove_file /opt/zoom/Qt/plugins/egldeviceintegrations/libqeglfs-emu-integration.so

remove_file /opt/zoom/Qt/plugins/audio/libqt*.so
# bug?
remove_file /opt/zoom/Qt/plugins/audio/libqtmedia_pulse.so
remove_file /opt/zoom/Qt/plugins/audio/libqtmedia_alsa.so
remove_file /opt/zoom/Qt/qml/QtQuick/Particles.2/libparticlesplugin.so
remove_file /opt/zoom/Qt/qml/QtQuick/LocalStorage/libqmllocalstorageplugin.so
remove_file /opt/zoom/Qt/qml/QtQuick/XmlListModel/libqmlxmllistmodelplugin.so
remove_file /opt/zoom/Qt/qml/QtQml/RemoteObjects/libqtqmlremoteobjects.so

add_libs_requires
