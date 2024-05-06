#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt

rm -v ./usr/bin/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT.sh

add_libs_requires
