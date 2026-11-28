#!/bin/sh

PKGNAME=topomatic360
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Topomatic 360 - BIM/IFC model viewer from the official site"
URL="https://topomatic.ru/products/topomatic360/"

. $(dirname $0)/common.sh

URLBASE="https://download.topomatic.ru/public/products/topomatic360"

if [ "$VERSION" = "*" ] ; then
    # -latest redirects to the versioned file: /d/products/topomatic360/topomatic360-linux-x86_64-1.4.5.rpm
    PKGURL="$(eget --get-real-url "$URLBASE/topomatic360-linux-x86_64-latest.rpm")" || fatal "Can't get package URL"
else
    # only some old versions are kept on the server
    PKGURL="$URLBASE/topomatic360-linux-x86_64-$VERSION.rpm"
fi

install_pkgurl
