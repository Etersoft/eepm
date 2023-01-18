#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ungoogled-chromium

. $(dirname $0)/common.sh

#subst '1iAutoProv:no' $SPEC

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
subst "s|^License: unknown$|License: BSD-3-Clause license|" $SPEC
subst "s|^Summary:.*|Summary: Google Chromium, sans integration with Google|" $SPEC

mkdir $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT/opt/$PRODUCT
subst "s|\"/$ROOTDIR/|\"/opt/$PRODUCT/|" $SPEC

add_bin_link_command

# TODO: unsupported
