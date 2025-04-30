#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command fdm $PRODUCTDIR/fdm

install_file $PRODUCTDIR/icon.png /usr/share/icons/hicolor/256x256/apps/$PRODUCT.png

fix_desktop_file $PRODUCTDIR/fdm fdm
fix_desktop_file $PRODUCTDIR/icon.png $PRODUCT.png

# libmimerapi.so dependency fix
remove_file /opt/freedownloadmanager/plugins/sqldrivers/libqsqlmimer.so

add_libs_requires
