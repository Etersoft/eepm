#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=signal-desktop
PRODUCTCUR=Signal
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common-chromium-browser.sh

install_deps

set_autoreq 'yes'

subst "s|.*/etc/apt.*||" $SPEC
subst '/linux-arm64/d' $SPEC
rm -rf $BUILDROOT/opt/Signal/resources/app.asar.unpacked/node_modules/ffi-napi/node_modules/ref-napi/prebuilds/linux-arm64

fix_chrome_sandbox

add_bin_link_command
