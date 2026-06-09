#!/bin/sh -x

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=teams-for-linux
PRODUCTDIR=/opt/teams-for-linux

. $(dirname $0)/common-chromium-browser.sh

add_bin_exec_command
fix_desktop_file "$PRODUCTDIR/$PRODUCT" "$PRODUCT"

# The package includes musl cbor-extract prebuilds next to glibc ones.
# On glibc systems they are unused and add an unresolvable libc.so()(64bit) require.
remove_file "$PRODUCTDIR/resources/app.asar.unpacked/node_modules/@cbor-extract/cbor-extract-linux-*/*.musl.node"

add_electron_deps
