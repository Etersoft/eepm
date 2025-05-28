#!/bin/sh

PKGNAME=freeplane
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="FreePlane from the official site"
URL="https://freeplane.sourceforge.net"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # PKGURL="$(get_json_value https://sourceforge.net/projects/$PKGNAME/best_release.json '["platform_releases","linux","url"]')"
    VERSION="1.12.10"
fi
PKGURL="https://download.sourceforge.net/project/freeplane/freeplane%20stable/freeplane_$VERSION~upstream-1_all.deb"

install_pkgurl
