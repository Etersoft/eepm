#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Viber
PRODUCTCUR=viber
PRODUCTDIR=/opt/viber

. $(dirname $0)/common.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

#subst '1i%filter_from_requires /^libtiff.so.5(LIBTIFF_.*/d' $SPEC

fix_desktop_file

add_libs_requires
