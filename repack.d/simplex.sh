#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

install_file $PRODUCTDIR/lib/simplex-simplex.desktop /usr/share/applications/simplex-simplex.desktop
install_file $PRODUCTDIR/lib/simplex.png /usr/share/icons/hicolor/512x512/apps/simplex.png

ignore_lib_requires 'libglapi.so.0()(64bit)'

