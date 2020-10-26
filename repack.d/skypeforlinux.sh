#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=skype
# move binaries from /usr/share/PKGNAME to _libdir/PKGNAME
#LIBDIR=$(rpmbuild --eval %_libdir 2>/dev/null)
LIBDIR=/opt

mkdir -p $BUILDROOT$LIBDIR/
mv $BUILDROOT/usr/share/skypeforlinux/ $BUILDROOT$LIBDIR/$PRODUCT/
subst "s|/usr/share/skypeforlinux|$LIBDIR/$PRODUCT|g" $SPEC

subst "s|^SKYPE_PATH=.*|SKYPE_PATH=$LIBDIR/$PRODUCT/skypeforlinux|" $BUILDROOT/usr/bin/skypeforlinux

subst '1iAutoProv:no' $SPEC

# ignore embedded libs
subst '1i%filter_from_requires /^libGLESv2.so().*/d' $SPEC
subst '1i%filter_from_requires /^libEGL.so().*/d' $SPEC
subst '1i%filter_from_requires /^libffmpeg.so().*/d' $SPEC

mkdir -p $BUILDROOT/usr/bin/
ln -s /usr/bin/skypeforlinux $BUILDROOT/usr/bin/skype
subst 's|%files|%files\n/usr/bin/skype|' $SPEC
