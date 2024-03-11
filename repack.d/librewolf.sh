#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=librewolf

. $(dirname $0)/common.sh

move_to_opt
fix_desktop_file "/usr/share/$PRODUCT/$PRODUCT"

add_libs_requires

rm usr/bin/librewolf
add_bin_link_command
