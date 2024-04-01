#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Popcorn-Time
PRODUCTCUR=popcorn-time
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

chmod -v -R a+rX .$PRODUCTDIR

add_bin_link_command $PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_chrome_sandbox

fix_desktop_file

add_libs_requires
