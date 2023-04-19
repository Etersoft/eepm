#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=geogebra-classic
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

subst '1iAutoReq:yes,noshell,nomonolib,nomono,nopython' $SPEC

subst '1iBuildRequires:rpm-build-python3' $SPEC
subst "1i%add_python3_path $PRODUCTDIR" $SPEC

move_to_opt
subst "s|/usr/share/$PRODUCT|$PRODUCTDIR|" $BUILDROOT/usr/bin/$PRODUCT

cleanup

fix_chrome_sandbox

install_deps
if [ "$(epm print info -s)" = "alt" ] ; then
    epm install --skip-installed python3 rpm-build-python3
fi
