#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/RememberTheMilk

. $(dirname $0)/common-chromium-browser.sh

cleanup

add_bin_link_command

add_electron_deps

fix_chrome_sandbox

fix_desktop_file
