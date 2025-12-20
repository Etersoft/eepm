#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

PRODUCTDIR=/opt/Ferdium

add_bin_link_command

fix_desktop_file


add_electron_deps
