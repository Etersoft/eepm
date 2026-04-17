#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# bundled Qt6, serial port module not bundled (optional)
ignore_lib_requires 'libQt6SerialPort.so.*'

# conflicts with MAX from AppImage
add_conflicts MAX

# replace old wine-based package
add_obsoletes max-qt
move_to_opt

fix_desktop_file /usr/share/max/bin/max

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT
