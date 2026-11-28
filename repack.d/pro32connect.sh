#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=pro32connect
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# the original scripts only restart the service on upgrade and disable it on removal
add_bin_link_command

fix_desktop_file
