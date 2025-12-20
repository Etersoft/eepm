#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=geogebra-classic
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

subst "s|/usr/share/$PRODUCT|$PRODUCTDIR|" $BUILDROOT/usr/bin/$PRODUCT

cleanup


add_electron_deps
