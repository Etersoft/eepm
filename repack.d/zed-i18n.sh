#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=zed-i18n
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command zed $PRODUCTDIR/bin/zed
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/zed
add_conflicts zed
