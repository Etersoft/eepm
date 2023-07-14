#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

PRODUCT=remotedesktopmanager
PRODUCTDIR=/usr/lib/devolutions/RemoteDesktopManager

add_findreq_skiplist "$PRODUCTDIR/runtimes/*"

set_autoreq 'yes'
