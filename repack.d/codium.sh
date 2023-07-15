#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=codium

. $(dirname $0)/common.sh

move_to_opt

add_electron_deps

remove_file /usr/bin/$PRODUCT
add_bin_link_command

fix_desktop_file /usr/share/codium/codium

fix_chrome_sandbox
