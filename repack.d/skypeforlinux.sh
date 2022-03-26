#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=skype
PRODUCTDIR=/opt/skype

. $(dirname $0)/common-chromium-browser.sh

# remove key install script
rm -rvf $BUILDROOT/opt/skypeforlinux/
subst "s|.*/opt/skypeforlinux/.*||" $SPEC

mkdir -p $BUILDROOT$PRODUCTDIR/
mv $BUILDROOT/usr/share/skypeforlinux/* $BUILDROOT$PRODUCTDIR/
subst "s|/usr/share/skypeforlinux|$PRODUCTDIR|g" $SPEC

subst "s|^SKYPE_PATH=.*|SKYPE_PATH=$PRODUCTDIR/skypeforlinux|" $BUILDROOT/usr/bin/skypeforlinux

subst '1iAutoProv:no' $SPEC

# ignore embedded libs
subst '1i%filter_from_requires /^libGLESv2.so().*/d' $SPEC
subst '1i%filter_from_requires /^libEGL.so().*/d' $SPEC
subst '1i%filter_from_requires /^libffmpeg.so().*/d' $SPEC

# usual command skype
mkdir -p $BUILDROOT/usr/bin/
ln -s /usr/bin/skypeforlinux $BUILDROOT/usr/bin/skype
subst 's|%files|%files\n/usr/bin/skype|' $SPEC

fix_chrome_sandbox
