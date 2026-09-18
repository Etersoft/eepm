#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=Bettbox

. $(dirname $0)/common.sh

# Bettbox is a GTK application with this application ID.  Without
# StartupWMClass, desktop environments cannot associate its running window
# with the icon declared in its desktop file.
subst '/^StartupNotify=/aStartupWMClass=com.appshub.bettbox' "$BUILDROOT/usr/share/applications/$PRODUCT.desktop"
