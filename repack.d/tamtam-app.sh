#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=TamTam
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

subst '1iAutoProv:no' $SPEC

mkdir -p $BUILDROOT/usr/bin/
ln -sf $PRODUCTDIRT/tamtam $BUILDROOT/usr/bin/tamtam

subst "s|%files|%files\n%_bindir/tamtam|" $SPEC

fix_chrome_sandbox
