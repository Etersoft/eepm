#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

# previous package name
add_conflicts zen

remove_file $PRODUCTDIR/update-settings.ini
remove_file $PRODUCTDIR/updater
remove_file $PRODUCTDIR/updater.ini

add_libs_requires

set_alt_alternatives 65
