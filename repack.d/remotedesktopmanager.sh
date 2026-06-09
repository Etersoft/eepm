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

if [ "$(epm print info -s)" = "fedora" ] ; then
    # Fedora no longer provides WebKitGTK 4.0; keep the bundled WebKitGTK 4.1 backend.
    remove_file "$PRODUCTDIR/libWebView-4.0.so"

    # The .NET tracepoint provider is optional and adds an unavailable liblttng-ust.so.0 requirement.
    remove_file "$PRODUCTDIR/libcoreclrtraceptprovider.so"
fi

# add_findreq_skiplist "$PRODUCTDIR/runtimes/*"

# set_autoreq 'yes'
