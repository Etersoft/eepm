#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# org.kde.config does not publish a QML provide in ALT.
add_requires kf6-kconfig
# org.kde.sonnet does not publish a QML provide in ALT.
add_requires libkf6sonnetui
add_unirequires 'qml6(org.kde.kirigamiaddons.settings)' 'qml6(org.kde.desktop)'

# Kwi uses system Qt6 rather than bundling it.
add_unirequires libQt6Core.so.6 libQt6DBus.so.6 libQt6Gui.so.6 libQt6Network.so.6 \
    libQt6Qml.so.6 libQt6Quick.so.6 libQt6QuickControls2.so.6 libQt6Widgets.so.6
