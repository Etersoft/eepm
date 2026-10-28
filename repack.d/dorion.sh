#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=Dorion

. $(dirname $0)/common.sh

# Dorion is a Tauri application (Rust + WebView)
# License is GPL-3.0 per https://github.com/SpikeHD/Dorion

# Fix empty License field from original package
subst "s|^License:.*|License: GPL-3.0|" $SPEC

# Shared-CEF RPMs use /usr/lib/Dorion, while bundled-CEF DEBs use lowercase
# /usr/lib/dorion and bundle CEF. Move either payload next to the binary.
PRODUCTSRCDIR=/usr/lib/$PRODUCT
[ -d "$BUILDROOT/usr/lib/dorion" ] && PRODUCTSRCDIR=/usr/lib/dorion
move_to_opt "$PRODUCTSRCDIR"

# Move binary from /usr/bin to /opt/Dorion
move_file /usr/bin/$PRODUCT $PRODUCTDIR/$PRODUCT

add_bin_link_command $PRODUCT
add_bin_link_command dorion $PRODUCT
