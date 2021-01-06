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


# Set SUID for chrome-sandbox if userns_clone is not supported
userns_path='/proc/sys/kernel/unprivileged_userns_clone'
userns_val="$(cat $userns_path 2>/dev/null)"
[ "$userns_val" = '1' ] || chmod 4755 $BUILDROOT/$LIBDIR/$PRODUCT/chrome-sandbox
