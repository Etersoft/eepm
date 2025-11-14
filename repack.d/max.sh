#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=MAX
PRODUCTCUR=max
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

fix_chrome_sandbox

fix_desktop_file $PRODUCTDIR/$PRODUCT $PRODUCTCUR

add_bin_link_command $PRODUCTCUR $PRODUCTDIR/$PRODUCT

remove_file $PRODUCTDIR/resources/app-update.yml

add_electron_deps

add_libs_requires
