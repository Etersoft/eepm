#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=fluffychat
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# libdartjni is not linked by fluffychat and only adds an unsatisfied libjvm requirement.
remove_file $PRODUCTDIR/lib/libdartjni.so

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT
