#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Pachca

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command
add_bin_link_command pachca $PRODUCT

fix_desktop_file /opt/Pachca/Pachca

add_electron_deps
