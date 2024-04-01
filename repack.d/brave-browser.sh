#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=brave-browser
PRODUCTCUR=brave-browser-stable
PRODUCTDIR=/opt/brave.com/brave

. $(dirname $0)/common-chromium-browser.sh

add_conflicts brave-browser-beta brave-browser-dev brave-browser-nightly

set_alt_alternatives 80

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

add_chromium_deps

fix_desktop_file /usr/bin/$PRODUCTCUR

