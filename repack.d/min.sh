#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=min
PRODUCTCUR=Min
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common-chromium-browser.sh

cleanup

add_chromium_deps

set_alt_alternatives 65

fix_chrome_sandbox

add_bin_exec_command $PRODUCT $PRODUCTDIR/$PRODUCT 

fix_desktop_file
