#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=slack
PRODUCTDIR=/usr/lib/slack

. $(dirname $0)/common-chromium-browser.sh

#move_to_opt

fix_chrome_sandbox

install_deps

cleanup

add_bin_exec_command

set_autoreq 'yes'
