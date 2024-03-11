#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Tonkeeper
PRODUCTCUR=tonkeeper
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

rm ./usr/bin/$PRODUCT
add_bin_link_command $PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_chrome_sandbox

add_electron_deps

