#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command fortivpn

mkdir -p var/lib/$PRODUCT
pack_dir /var/lib/$PRODUCT
remove_file $PRODUCTDIR/update

add_electron_deps
