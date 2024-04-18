#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=balena-etcher
PRODUCTDIR=/opt/balena-etcher

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

add_bin_link_command
fix_desktop_file

fix_chrome_sandbox
add_electron_deps
