#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vinteo.desktop
PRODUCTDIR=/opt/VinteoDesktop/

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command vinteo.desktop
add_bin_link_command $PRODUCT $PRODUCTDIR/vinteo.desktop

fix_chrome_sandbox
