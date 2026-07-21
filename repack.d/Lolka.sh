#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_electron_deps

fix_desktop_file /opt/Lolka/lolka $PRODUCT

add_bin_link_command $PRODUCT /opt/$PRODUCT/lolka
