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

if [ "$(epm print info -s)" = "alt" ] ; then
    epm install --skip-installed libGL libqt5-core libqt5-gui libqt5-network libqt5-printsupport libqt5-qml libqt5-svg libqt5-widgets libsane zlib
fi
