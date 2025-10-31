#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

PRODUCT=remotedesktopmanager
PRODUCTDIR=/opt/$PRODUCT
PRODUCTCUR=RemoteDesktopManager

move_file /bin/$PRODUCT /usr/bin/$PRODUCT

subst "s|/usr/lib/devolutions/RemoteDesktopManager/RemoteDesktopManager|$PRODUCTDIR/$PRODUCTCUR|" $BUILDROOT/usr/bin/$PRODUCT

move_to_opt /usr/lib/devolutions/RemoteDesktopManager

# add_findreq_skiplist "$PRODUCTDIR/runtimes/*"

# set_autoreq 'yes'
add_libs_requires
