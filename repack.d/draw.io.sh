#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=draw.io
PRODUCTDIR=/opt/drawio/

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command drawio
add_bin_link_command $PRODUCT $PRODUCTDIR/drawio

fix_chrome_sandbox
