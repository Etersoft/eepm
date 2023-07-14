#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vk
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

fix_chrome_sandbox

add_electron_deps

remove_dir /etc

rm -f $BUILDROOT/usr/bin/vk
add_bin_link_command
