#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=tlclient
PRODUCTCUR=thinlinc
PRODUCTDIR=/opt/thinlinc

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT
add_bin_exec_command $PRODUCTCUR $PRODUCT

fix_desktop_file "/opt/thinlinc/bin/tlclient-openconf"

add_libs_requires
