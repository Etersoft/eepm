#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=pencil
PRODUCTDIR=/opt/Pencil
PRODUCTCUR=Pencil

. $(dirname $0)/common-chromium-browser.sh

add_conflicts pencil

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

add_electron_deps

fix_chrome_sandbox

fix_desktop_file

