#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=breez
PRODUCTDIR=/opt/breez

. $(dirname $0)/common.sh

# the original %post creates the link /usr/bin/breez
add_bin_link_command
fix_desktop_file

# used only by the original %post (Ubuntu AppArmor)
remove_file $PRODUCTDIR/resources/apparmor-profile

add_electron_deps
