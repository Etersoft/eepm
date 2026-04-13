#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# fplus-upd-ppd and lexmark-upd-ppd share the same CUPS filter files
add_conflicts lexmark-upd-ppd
