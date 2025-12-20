#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

# FIXME: unpacked??
PRODUCTDIR=/opt/deepseek-desktop/unpacked

. $(dirname $0)/common.sh

remove_file /opt/deepseek-desktop/icon.png

add_bin_link_command $PRODUCT

