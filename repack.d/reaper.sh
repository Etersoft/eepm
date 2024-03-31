#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/REAPER
. $(dirname $0)/common.sh

add_bin_link_command
