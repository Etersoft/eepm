#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command fdm $PRODUCTDIR/fdm

install_file $PRODUCTDIR/icon.png /usr/share/icons/hicolor/256x256/apps/$PRODUCT.png

fix_desktop_file $PRODUCTDIR/fdm fdm
fix_desktop_file $PRODUCTDIR/icon.png $PRODUCT.png

# remove unused sql dependencies (but keep libqsqlite)
remove_file "$PRODUCTDIR/plugins/sqldrivers/libqsqlmimer.so"
remove_file "$PRODUCTDIR/plugins/sqldrivers/libqsqlmysql.so"
remove_file "$PRODUCTDIR/plugins/sqldrivers/libqsqlodbc.so"
remove_file "$PRODUCTDIR/plugins/sqldrivers/libqsqlpsql.so"

add_libs_requires
