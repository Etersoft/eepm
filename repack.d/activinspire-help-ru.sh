#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=activinspire
PRODUCTDIR=/opt/$PRODUCT/help/ru

. $(dirname $0)/common.sh

# see repack.d/activinspire.sh
move_to_opt /usr/local/bin/activsoftware/help/ru
remove_dir /usr/local
