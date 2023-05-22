#!/bin/sh

PKGNAME=freeplane
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="FreePlane from the official site"
URL="http://freeplane.sourceforge.net"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="$(eget -O- https://sourceforge.net/projects/$PKGNAME/best_release.json | sed -e 's|.*freeplane_bin-||g' -e 's|\.zip.*||')"

PKGURL="https://nav.dl.sourceforge.net/project/freeplane/freeplane%20stable/freeplane_$VERSION~upstream-1_all.deb"

epm install "$PKGURL"
