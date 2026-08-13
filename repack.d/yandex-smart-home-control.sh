#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-smart-home-control
PRODUCTDIR=/opt/$PRODUCT
OLDPRODUCTDIR="/opt/Yandex Smart Home Control"

. $(dirname $0)/common-chromium-browser.sh

if [ -d "$BUILDROOT$OLDPRODUCTDIR" ] ; then
    move_to_opt "$OLDPRODUCTDIR" || fatal
fi

add_bin_link_command $PRODUCT "$PRODUCTDIR/$PRODUCT"

subst "s|^Exec=.*$PRODUCT.*|Exec=$PRODUCT|" "$BUILDROOT"/usr/share/applications/*.desktop

add_electron_deps
