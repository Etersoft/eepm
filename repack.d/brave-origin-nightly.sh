#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=brave-origin
PRODUCTCUR=brave-origin-nightly
PRODUCTDIR=/opt/brave.com/brave-origin-nightly

. $(dirname $0)/common-chromium-browser.sh

add_conflicts brave-origin brave-origin-beta

set_alt_alternatives 80

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

add_chromium_deps

remove_file /usr/share/applications/com.brave.Origin.nightly.desktop
