#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT.sh

fix_desktop_file "/usr/bin/$PRODUCT"

remove_dir /usr/lib/mime

add_requires java-openjdk
