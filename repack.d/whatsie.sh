#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# generic-snap.sh removes bundled Qt from gnome-platform/,
# so we need to add dependencies on system Qt
add_libs_requires
add_unirequires libQt6Core.so.6 libQt6DBus.so.6 libQt6Gui.so.6 libQt6Network.so.6 libQt6Positioning.so.6 libQt6WebEngineCore.so.6 libQt6WebEngineWidgets.so.6 libQt6Widgets.so.6
