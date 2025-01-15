#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=skype
PRODUCTCUR=skypeforlinux
PRODUCTDIR=/opt/skypeforlinux

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command $PRODUCTCUR $PRODUCTDIR/$PRODUCTCUR
add_bin_link_command $PRODUCT $PRODUCTCUR

fix_chrome_sandbox

fix_desktop_file /usr/bin/skypeforlinux
fix_desktop_file '${SNAP}/meta/gui/skypeforlinux.png' skypeforlinux.png

add_electron_deps

