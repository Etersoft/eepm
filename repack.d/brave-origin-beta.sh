#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=brave-origin
PRODUCTCUR=brave-origin-beta
PRODUCTDIR=/opt/brave.com/brave-origin-beta

. $(dirname $0)/common-chromium-browser.sh

add_conflicts brave-origin brave-origin-nightly

set_alt_alternatives 80

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

add_chromium_deps

remove_file /usr/share/applications/com.brave.Origin.beta.desktop
