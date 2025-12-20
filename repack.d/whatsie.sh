#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Qt5 dependencies: generic-snap.sh removes bundled Qt from gnome-platform/,
# so we need to add dependencies on system Qt
add_unirequires libQt5Core.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5Positioning.so.5 libQt5WebEngineCore.so.5 libQt5WebEngineWidgets.so.5 libQt5Widgets.so.5
