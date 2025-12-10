#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/r7-office

. $(dirname $0)/common.sh

fix_desktop_file /usr/bin/r7-office-desktopeditors
fix_desktop_file /usr/bin/r7-office-imageviewer
fix_desktop_file /usr/bin/r7-office-videoplayer

add_libs_requires
