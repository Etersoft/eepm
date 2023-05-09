#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=gitkraken

. $(dirname $0)/common-chromium-browser.sh

rm -v ./usr/bin/gitkraken
add_bin_link_command

install_deps

move_to_opt

fix_chrome_sandbox

fix_desktop_file /usr/share/gitkraken/gitkraken
fix_desktop_file /usr/bin/gitkraken

add_findreq_skiplist "$PRODUCTDIR/resources/app.asar.unpacked/node_modules/@axosoft/*/build/Release/*.node"
add_findreq_skiplist "$PRODUCTDIR/resources/app.asar.unpacked/node_modules/@msgpackr-extract/msgpackr-extract-linux-x64/*.node"

add_requires libXScrnSaver
