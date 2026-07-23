#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# both native and wine claude-desktop provide /usr/bin/claude-desktop
add_conflicts claude-desktop-wine

move_to_opt /usr/lib/claude-desktop

# /usr/bin/claude-desktop is a symlink into the app dir; re-point it at /opt
# after the move (subst can't rewrite a symlink target)
rm -f "$BUILDROOT/usr/bin/$PRODUCT"
add_bin_link_command $PRODUCT "$PRODUCTDIR/$PRODUCT"

fix_desktop_file /usr/bin/$PRODUCT $PRODUCT

add_electron_deps
