#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=TamTam
LIBDIR=/opt

subst '1iAutoProv:no' $SPEC

mkdir -p $BUILDROOT/usr/bin/
ln -sf $LIBDIR/$PRODUCT/tamtam $BUILDROOT/usr/bin/tamtam

subst "s|%files|%files\n%_bindir/tamtam|" $SPEC
