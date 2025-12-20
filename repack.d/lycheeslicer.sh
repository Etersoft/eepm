#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=lycheeslicer
PRODUCTDIR=/opt/LycheeSlicer

. $(dirname $0)/common.sh

add_bin_link_command

fix_desktop_file

add_electron_deps

