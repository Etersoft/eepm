#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ayugram
PRODUCTCUR=AyuGram
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# /usr/bin/AyuGram

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCT

add_libs_requires
