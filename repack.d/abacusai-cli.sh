#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=abacusai-cli
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command abacusai $PRODUCTDIR/abacusai
