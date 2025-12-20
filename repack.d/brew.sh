#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=brew
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

