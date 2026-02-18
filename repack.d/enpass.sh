#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

fix_desktop_file /opt/enpass/Enpass $PRODUCT

add_bin_link_command $PRODUCT /opt/$PRODUCT/Enpass
