#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=min
PRODUCTCUR=Min
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common-chromium-browser.sh

cleanup

add_electron_deps

set_alt_alternatives 65

add_bin_exec_command $PRODUCT $PRODUCTDIR/$PRODUCT 

fix_desktop_file

# hack against error: unpacking of archive failed on file /usr/share/icons/hicolor/256x256/apps/min.png;67da644b: cpio: link
# the file also placed in /opt and when /opt and /usr is not the same fs, cpio can't unpack?
cd usr/share/icons/hicolor/256x256/apps
cp min.png min.png.copy
mv min.png.copy min.png
