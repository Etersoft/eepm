#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=PureRef
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt /usr/bin

add_bin_exec_command pureref $PRODUCTDIR/$PRODUCT

add_libs_requires
