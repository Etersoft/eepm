#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=waywallen

. $(dirname $0)/common.sh

install_file $PRODUCTDIR/org.waywallen.waywallen.svg /usr/share/icons/hicolor/scalable/apps/org.waywallen.waywallen.svg
fix_desktop_file "Categories=Graphics;Qt;" "Categories=Settings;DesktopSettings;Qt;"

# Waywallen uses Qcm.Material dialogs and does not import these optional QML
# modules. Their plugins only add dependencies on Qt libraries absent from the AppImage.
remove_file $PRODUCTDIR/usr/qml/QtQuick/Dialogs/libqtquickdialogsplugin.so
remove_file $PRODUCTDIR/usr/qml/QtQuick/Dialogs/quickimpl/libqtquickdialogs2quickimplplugin.so
remove_file $PRODUCTDIR/usr/qml/QtQuick/Particles/libparticlesplugin.so
remove_file $PRODUCTDIR/usr/qml/QtQuick/Shapes/DesignHelpers/libqtquickshapesdesignhelpersplugin.so
remove_file $PRODUCTDIR/usr/qml/QtQuick/Controls/libqtquickcontrols2plugin.so
remove_file $PRODUCTDIR/usr/qml/QtQuick/Controls/impl/libqtquickcontrols2implplugin.so
remove_file $PRODUCTDIR/usr/qml/QtQuick/Controls/Native/libqtquickcontrols2nativestyleplugin.so
remove_file $PRODUCTDIR/usr/qml/QtQuick/Templates/libqtquicktemplates2plugin.so

cat <<EOF | create_file /usr/lib/systemd/user/waywallen.service
[Unit]
Description=Waywallen wallpaper daemon
Documentation=https://github.com/waywallen/waywallen
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/waywallen --no-ui --no-tray
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF
