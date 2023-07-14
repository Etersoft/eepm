#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=express
PRODUCTDIR=/opt/eXpress

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command

fix_desktop_file

add_electron_deps

fix_chrome_sandbox
