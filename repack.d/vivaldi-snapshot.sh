#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vivaldi
PRODUCTCUR=vivaldi-snapshot
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common-chromium-browser.sh

subst '1iConflicts:vivaldi-stable' $SPEC

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

fix_desktop_file /usr/bin/$PRODUCTCUR

install_deps

add_findreq_skiplist $PRODUCTDIR/update-ffmpeg

filter_from_requires '\\/opt\\/google\\/chrome\\/WidevineCdm'

set_autoreq 'yes'

echo "You also can install chrome via epm play chrome to use WidevineCdm"

