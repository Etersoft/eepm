#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=min
PRODUCTCUR=Min
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

cleanup

add_chromium_deps

fix_chrome_sandbox

fix_desktop_file
