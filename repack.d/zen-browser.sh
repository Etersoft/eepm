#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=zen-browser

. $(dirname $0)/common-chromium-browser.sh

# rename from "zen" (generic-appimage parses short name from AppImage filename)
subst "s|^Name:.*|Name: $PRODUCT|" $SPEC

# previous package name
add_conflicts zen

remove_file $PRODUCTDIR/update-settings.ini
remove_file $PRODUCTDIR/updater
remove_file $PRODUCTDIR/updater.ini


set_alt_alternatives 65
