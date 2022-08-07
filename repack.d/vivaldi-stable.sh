#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vivaldi
PRODUCTCUR=vivaldi-stable
PRODUCTDIR=/opt/vivaldi

. $(dirname $0)/common-chromium-browser.sh

subst '1iConflicts:vivaldi-snapshot' $SPEC

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps

filter_from_requires '\\/opt\\/google\\/chrome\\/WidevineCdm'

echo "You also can install chrome via epm play chrome to use WidevineCdm"
