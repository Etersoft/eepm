#!/bin/sh

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command git-writer "$PRODUCTDIR/bin/GitWriter"
desktop=/usr/share/applications/gitwriter-GitWriter.desktop
install_file "$PRODUCTDIR/lib/gitwriter-GitWriter.desktop" "$desktop"
subst 's/^Categories=Unknown$/Categories=Office;/' "$BUILDROOT$desktop"
