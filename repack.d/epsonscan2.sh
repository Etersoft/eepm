#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_unirequires udev

fix_desktop_file /usr/bin/epsonscan2

#  Application depends on external Qt5 libraries
add_unirequires 'libQt5Core.so.5' 'libQt5Gui.so.5' 'libQt5Widgets.so.5'

add_libs_requires
