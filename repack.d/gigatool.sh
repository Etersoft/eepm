#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=multitool
PRODUCTDIR=/opt/MultiTool

. $(dirname $0)/common-chromium-browser.sh

add_bin_exec_command
fix_desktop_file
add_electron_deps
