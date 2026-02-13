#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt

add_electron_deps

fix_desktop_file /usr/share/qoder/qoder

add_bin_link_command $PRODUCT /opt/$PRODUCT/bin/qoder
