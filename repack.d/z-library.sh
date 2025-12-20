#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/Z-Library

. $(dirname $0)/common-chromium-browser.sh

# hack
remove_file /usr/bin/$PRODUCT
add_bin_link_command

fix_desktop_file /opt/Z-Library/z-library


add_electron_deps
