#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=mobirise
PRODUCTDIR=/opt/Mobirise

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command

fix_desktop_file

fix_chrome_sandbox

# use both
add_electron_deps
add_libs_requires
