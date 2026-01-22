#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

ignore_lib_requires libQt6Charts.so.6 libQt6Core.so.6 libQt6Gui.so.6 libQt6Network.so.6 libQt6Widgets.so.6


