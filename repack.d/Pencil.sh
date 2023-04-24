#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=pencil
PRODUCTDIR=/opt/Pencil
PRODUCTCUR=Pencil

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

install_deps

fix_chrome_sandbox

fix_desktop_file

subst '1iConflicts: pencil' $SPEC
