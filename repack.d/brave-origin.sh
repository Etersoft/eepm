#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=brave-origin
PRODUCTCUR=brave-origin-stable
PRODUCTDIR=/opt/brave.com/brave-origin

. $(dirname $0)/common-chromium-browser.sh

add_conflicts brave-origin-beta brave-origin-nightly

set_alt_alternatives 80

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

add_chromium_deps

fix_desktop_file /usr/bin/$PRODUCTCUR
remove_file /usr/share/applications/com.brave.Origin.desktop
