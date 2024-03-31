#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=obsidian
PRODUCTCUR=obsidian
PRODUCTDIR=/opt/Obsidian


. $(dirname $0)/common-chromium-browser.sh

cleanup

rm usr/bin/$PRODUCT
add_bin_exec_command

add_chromium_deps

fix_chrome_sandbox

fix_desktop_file
