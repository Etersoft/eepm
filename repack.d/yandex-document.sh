#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt "/usr/lib/$PRODUCT"

# The vendor launcher refers to the original /usr/lib location. Replace it
# after moving the Electron bundle to /opt.
rm -f "$BUILDROOT/usr/bin/$PRODUCT"
add_bin_link_command "$PRODUCT" "$PRODUCTDIR/$PRODUCT"

fix_desktop_file "/usr/bin/$PRODUCT" "$PRODUCT"

add_electron_deps
