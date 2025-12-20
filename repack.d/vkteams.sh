#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vkteams

. $(dirname $0)/common.sh

move_to_opt /usr/local/vkteams
fix_desktop_file /usr/local/vkteams/vkteams
fix_desktop_file /usr/share/pixmaps/vkteams.png vkteams

# TODO: drop or mask all Qt plugins?

# to skip obsoleted require libjasper.so.1()(64bit)
remove_file $PRODUCTDIR/plugins/imageformats/libqjp2.so

# drop unneeded plugins
remove_file "$PRODUCTDIR/plugins/sqldrivers/*.so"

# libavcodec.so.61()(64bit)
# libavformat.so.61()(64bit)
# libavutil.so.59()(64bit)
remove_file $PRODUCTDIR/plugins/multimedia/libffmpegmediaplugin.so

remove_file $PRODUCTDIR/lib/libswresample.so.5.1.100
remove_file $PRODUCTDIR/lib/libswscale.so.8.1.100

# linked with libtinfo.so.5 (we have compatibility only on ALT)
remove_file $PRODUCTDIR/lib/libGLsoft.so.1

add_bin_link_command

