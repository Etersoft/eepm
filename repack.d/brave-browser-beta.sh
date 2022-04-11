#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=brave-browser
PRODUCTCUR=brave-browser-beta
PRODUCTDIR=/opt/brave.com/brave-beta

. $(dirname $0)/common-chromium-browser.sh

subst '1iConflicts:brave-browser-nightly' $SPEC

set_alt_alternatives 80

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps

