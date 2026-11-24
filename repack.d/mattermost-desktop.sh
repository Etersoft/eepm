#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/Mattermost

. $(dirname $0)/common.sh

add_electron_deps

target="$PRODUCTDIR/$PRODUCT"
if [ -f "$BUILDROOT$PRODUCTDIR/com.Mattermost.Desktop" ] ; then
    target="$PRODUCTDIR/com.Mattermost.Desktop"
fi
add_bin_link_command "$PRODUCT" "$target"
fix_desktop_file "$target" "$PRODUCT"
