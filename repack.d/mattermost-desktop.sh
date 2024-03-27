#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/Mattermost

. $(dirname $0)/common.sh

add_electron_deps

add_bin_link_command

fix_chrome_sandbox

fix_desktop_file
