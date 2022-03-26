#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Sferum
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

mkdir -p $BUILDROOT/usr/bin/
ln -s $PRODUCTDIR/sferum $BUILDROOT/usr/bin/sferum
subst 's|%files|%files\n/usr/bin/sferum|' $SPEC

fix_chrome_sandbox
