#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# move binaries from /usr/share/PKGNAME to _libdir/PKGNAME
LIBDIR=$(rpmbuild --eval %_libdir 2>/dev/null)
mkdir -p $BUILDROOT$LIBDIR/
mv $BUILDROOT/usr/share/skypeforlinux/ $BUILDROOT$LIBDIR/
subst "s|/usr/share/skypeforlinux|$LIBDIR/skypeforlinux|g" $SPEC

subst "s|^SKYPE_PATH=.*|SKYPE_PATH=$LIBDIR/skypeforlinux/skypeforlinux|" $BUILDROOT/usr/bin/skypeforlinux
