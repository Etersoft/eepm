#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=drawio
PRODUCTCUR=draw.io
PRODUCTDIR=/opt/drawio

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_desktop_file /opt/drawio/drawio

fix_chrome_sandbox
