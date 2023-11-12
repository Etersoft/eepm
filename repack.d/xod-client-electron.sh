#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=xod-client-electron
PRODUCTCUR=xod-ide
PRODUCTDIR="/opt/XOD IDE"

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT
add_bin_link_command "xod-client" $PRODUCT

fix_desktop_file "/opt/XOD IDE"

fix_chrome_sandbox

add_electron_deps
