#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt "/$PRODUCT-*"

add_libs_requires

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

