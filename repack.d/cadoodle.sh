#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTCUR=CaDoodle

. $(dirname $0)/common.sh

install_file /opt/cadoodle/lib/CaDoodle.png /usr/share/icons/hicolor/512x512/apps/$PRODUCTCUR.png
install_file /opt/cadoodle/lib/cadoodle-CaDoodle.desktop /usr/share/applications/$PRODUCTCUR.desktop

fix_desktop_file /opt/cadoodle/bin/CaDoodle $PRODUCTCUR
fix_desktop_file /opt/cadoodle/lib/CaDoodle.png $PRODUCTCUR

add_bin_link_command $PRODUCTCUR /opt/cadoodle/bin/CaDoodle
add_bin_link_command $PRODUCT $PRODUCTCUR

# requires old ffmpeg's libs
remove_file /opt/cadoodle/lib/runtime/lib/libavplugin-*.so
remove_file /opt/cadoodle/lib/runtime/lib/libavplugin-ffmpeg-*.so

