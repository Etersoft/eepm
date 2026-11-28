#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=svodly
PRODUCTCUR=svodly-desktop

. $(dirname $0)/common.sh

# svodly-desktop is the upstream command name, add the short one too
add_bin_link_command $PRODUCT $PRODUCTCUR

# non-standard icon dir from the Tauri bundler
move_file /usr/share/icons/hicolor/256x256@2/apps/$PRODUCTCUR.png /usr/share/icons/hicolor/512x512@2/apps/$PRODUCTCUR.png
remove_dir /usr/share/icons/hicolor/256x256@2

# match the desktop file name with the icon and StartupWMClass
move_file /usr/share/applications/Svodly.desktop /usr/share/applications/$PRODUCTCUR.desktop

add_libs_requires
