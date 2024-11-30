#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=slack
# PRODUCTDIR=/usr/lib/slack

. $(dirname $0)/common-chromium-browser.sh

move_to_opt "/usr/lib/$PRODUCT"
remove_file "/usr/bin/slack"

fix_chrome_sandbox

add_electron_deps

cleanup

add_bin_exec_command
