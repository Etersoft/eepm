#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=geogebra-classic
PRODUCTDIR=/opt/$PRODUCT

PREINSTALL_PACKAGES="python3 rpm-build-python3"

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

subst '1iBuildRequires:rpm-build-python3' $SPEC
if [ -z "$EPM_RPMBUILD" ] ; then
    subst "1i%add_python3_path $PRODUCTDIR" $SPEC
fi

subst "s|/usr/share/$PRODUCT|$PRODUCTDIR|" $BUILDROOT/usr/bin/$PRODUCT

cleanup

fix_chrome_sandbox

add_electron_deps
