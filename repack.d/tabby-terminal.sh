#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=tabby
PRODUCTDIR=/opt/Tabby

. $(dirname $0)/common.sh


add_libs_requires

add_bin_link_command

fix_desktop_file
