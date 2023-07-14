#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=lycheeslicer
PRODUCTDIR=/opt/LycheeSlicer

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command
#add_bin_link_command $PRODUCTCUR $PRODUCT

add_electron_deps

fix_chrome_sandbox

fix_desktop_file

# ignore embedded libs
filter_from_requires libQt5 node seamonkey thunderbird
