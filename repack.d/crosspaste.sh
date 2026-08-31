#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=crosspaste
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# The upstream deb adds its APT repository, which is not useful in repacked RPMs.
remove_dir /etc/apt

move_to_opt /usr/lib/$PRODUCT

remove_file /usr/bin/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

fix_desktop_file /usr/lib/$PRODUCT/bin/$PRODUCT $PRODUCT
