#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=flclashx
PRODUCTCUR=FlClashX

. $(dirname $0)/common.sh

move_to_opt

fix_desktop_file "$PRODUCTDIR/$PRODUCTCUR" $PRODUCT

add_bin_link_command $PRODUCT "$PRODUCTDIR/$PRODUCTCUR"
add_bin_link_command $PRODUCTCUR "$PRODUCTDIR/$PRODUCTCUR"
