#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=tamtam
PRODUCTCUR=TamTam
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common-chromium-browser.sh

cleanup

add_bin_exec_command $PRODUCT
add_bin_exec_command $PRODUCTCUR $PRODUCTDIR/$PRODUCT

fix_chrome_sandbox
