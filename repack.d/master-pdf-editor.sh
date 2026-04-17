#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=masterpdfeditor5
PRODUCTCUR=master-pdf-editor
PRODUCTDIR=/opt/master-pdf-editor-5

. $(dirname $0)/common.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_desktop_file

# uses system Qt5 (not bundled)
add_unirequires libQt5Concurrent.so.5 libQt5Core.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5PrintSupport.so.5 libQt5Qml.so.5 libQt5Svg.so.5 libQt5Widgets.so.5 libQt5Xml.so.5


