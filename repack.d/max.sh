#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=MAX
PRODUCTCUR=max
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# conflicts with MAX from AppImage
add_conflicts MAX

fix_chrome_sandbox

fix_desktop_file $PRODUCTDIR/$PRODUCT $PRODUCTCUR

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCTDIR/$PRODUCT

add_electron_deps

