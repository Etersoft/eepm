#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=nomachine
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

[ -x "$BUILDROOT$PRODUCTDIR/bin/nxplayer" ] || fatal "Can't find unpacked nxplayer"

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/nxplayer
