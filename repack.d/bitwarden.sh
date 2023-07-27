#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=bitwarden
PRODUCTDIR=/opt/Bitwarden

. $(dirname $0)/common.sh

add_electron_deps

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_chrome_sandbox

fix_desktop_file
