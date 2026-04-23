#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# both native and wine claude-desktop provide /usr/bin/claude-desktop
add_conflicts claude-desktop-wine

move_to_opt /usr/lib/claude-desktop

subst 's|/usr/lib/claude-desktop|/opt/claude-desktop|g' $BUILDROOT/usr/bin/$PRODUCT

fix_desktop_file /usr/bin/$PRODUCT $PRODUCT

add_electron_deps
