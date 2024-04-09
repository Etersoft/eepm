#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/Plex.sh

add_libs_requires
