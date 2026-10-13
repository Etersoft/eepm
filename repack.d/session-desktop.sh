#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=session-desktop
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_to_opt "/opt/Session"
fix_desktop_file "/opt/Session/$PRODUCT" "$PRODUCT"

add_bin_link_command

# used only for AppImage
remove_file $PRODUCTDIR/resources/launcher-script.sh
remove_file $PRODUCTDIR/resources/apparmor-profile

add_electron_deps
