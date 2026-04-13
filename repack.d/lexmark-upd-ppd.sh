#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# lexmark-upd-ppd and fplus-upd-ppd share the same CUPS filter files
add_conflicts fplus-upd-ppd
