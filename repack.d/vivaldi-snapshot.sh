#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vivaldi
PRODUCTCUR=vivaldi-snapshot
PRODUCTDIR=/opt/vivaldi

. $(dirname $0)/common-chromium-browser.sh

subst '1iConflicts:vivaldi-stable' $SPEC

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps

subst "1i%filter_from_requires /.opt.google.chrome.WidevineCdm/d" $SPEC

echo "You also can install chrome via epm play chrome to use WidevineCdm"
