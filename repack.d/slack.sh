#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=slack

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

fix_chrome_sandbox

install_deps

cleanup

#rm -f $BUILDROOT$PRODUCTDIR/$PRODUCT
#add_bin_link_command
add_bin_commands

subst '1iAutoProv:no' $SPEC

