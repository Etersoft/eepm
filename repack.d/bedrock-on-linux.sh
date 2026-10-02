#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=bedrock-on-linux
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt /usr/lib/$PRODUCT

# Drop broken symlink
remove_file /usr/bin/$PRODUCT
add_bin_exec_command

add_unirequires libwebkit2gtk-4.1.so.0

# Upstream pack all Qt libs why ?
# TODO: Create issue to it
remove_dir "$PRODUCTDIR/PySide6/Qt/qml"
remove_dir "$PRODUCTDIR/PySide6/Qt/plugins/designer"
remove_dir "$PRODUCTDIR/PySide6/Qt/plugins/qmltooling"
remove_file "$PRODUCTDIR/PySide6/Qt/plugins/imageformats/libqpdf.so"
remove_file "$PRODUCTDIR/PySide6/Qt/plugins/egldeviceintegrations/libqeglfs-kms-integration.so"
remove_file "$PRODUCTDIR/PySide6/Qt/plugins/platforminputcontexts/libqtvirtualkeyboardplugin.so"
remove_file "$PRODUCTDIR/PySide6/Qt/plugins/sqldrivers/libqsqlmimer.so"
remove_file "$PRODUCTDIR/PySide6/Qt/plugins/sqldrivers/libqsqlmysql.so"
remove_file "$PRODUCTDIR/PySide6/Qt/plugins/sqldrivers/libqsqlpsql.so"
