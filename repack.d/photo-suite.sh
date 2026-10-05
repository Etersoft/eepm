#!/bin/sh

BUILDROOT="$1"
SPEC="$2"
PRODUCT=PhotoSuite

. $(dirname $0)/common.sh

subst 's|^License:.*|License: GPL-3.0|' "$SPEC"

move_to_opt /usr/lib/$PRODUCT
