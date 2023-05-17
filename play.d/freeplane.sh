#!/bin/sh

PKGNAME=freeplane
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="FreePlane from the official site"
URL="http://freeplane.sourceforge.net"

. $(dirname $0)/common.sh

PKGURL="https://nav.dl.sourceforge.net/project/freeplane/freeplane%20stable/freeplane_1.11.2~upstream-1_all.deb"

if [ "$(epm print info -s)" = "alt" ] ; then
    repack="--repack"
fi

epm install $repack "$PKGURL"
