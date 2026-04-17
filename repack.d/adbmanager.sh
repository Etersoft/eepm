#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# uses system Qt6 via libQt6Pas (not bundled)
add_unirequires libQt6Pas.so.6 libQt6Core.so.6 libQt6DBus.so.6 libQt6Gui.so.6 libQt6PrintSupport.so.6 libQt6Widgets.so.6
