#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=google-chrome
PRODUCTCUR=google-chrome-stable
PRODUCTDIR=/opt/google/chrome


. $(dirname $0)/common-chromium-browser.sh

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps

