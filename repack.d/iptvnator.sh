#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=iptvnator
PRODUCTDIR=/opt/IPTVnator

. $(dirname $0)/common-chromium-browser.sh

cleanup
fix_chrome_sandbox
add_electron_deps

add_bin_link_command
