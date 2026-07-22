#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=AppFlowy
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Keep the generic-default behavior for full AppImage bundles.
stop_libs_requires

# AppFlowy's ELF interpreter is a relative lib64/ld-linux-x86-64.so.2.
mkdir -p "$BUILDROOT$PRODUCTDIR/lib64" || fatal
ln -snf /lib64/ld-linux-x86-64.so.2 "$BUILDROOT$PRODUCTDIR/lib64/ld-linux-x86-64.so.2" || fatal
pack_file "$PRODUCTDIR/lib64/ld-linux-x86-64.so.2"

fix_desktop_file /usr/bin/$PRODUCT $PRODUCT
subst "s|^Icon=.*|Icon=$PRODUCT|" "$BUILDROOT"/usr/share/applications/*.desktop
