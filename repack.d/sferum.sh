#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Sferum
PRODUCTCUR=sferum
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

cleanup

add_bin_exec_command $PRODUCTCUR
add_bin_exec_command $PRODUCT $PRODUCTDIR/$PRODUCTCUR

fix_chrome_sandbox

fix_desktop_file /opt/Sferum/sferum

set_autoreq 'yes'
