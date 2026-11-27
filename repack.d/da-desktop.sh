#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=abacusai
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt "/opt/AbacusAI Desktop" || fatal

# On glibc systems the module loaders select GNU builds, not bundled musl builds.
for dir in "$BUILDROOT$PRODUCTDIR"/resources/app.asar.unpacked/node_modules/@yuuang/ffi-rs-linux-*-musl \
           "$BUILDROOT$PRODUCTDIR"/resources/app.asar.unpacked/node_modules/@ff-labs/fff-bin-linux-*-musl ; do
    remove_dir "${dir#$BUILDROOT}"
done
for file in "$BUILDROOT$PRODUCTDIR"/resources/app.asar.unpacked/node_modules/zigpty/prebuilds/zigpty.linux-*-musl.node ; do
    remove_file "${file#$BUILDROOT}"
done

add_bin_link_command abacusai-desktop $PRODUCTDIR/abacusai-desktop
subst 's|^Exec=.*|Exec=abacusai-desktop %U|' "$BUILDROOT"/usr/share/applications/*.desktop

add_electron_deps
