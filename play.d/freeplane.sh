#!/bin/sh

PKGNAME=freeplane
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="FreePlane from the official site"
URL="https://freeplane.sourceforge.net"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_json_value https://sourceforge.net/projects/$PKGNAME/best_release.json '["platform_releases","linux","filename"]' | grep -oP '\d+\.\d+\.\d+')"
fi

# Yes, now with dot after version
case  $(epm print compare package version "$VERSION" 1.12.13) in
    1|0)
    file=freeplane_$VERSION.upstream-1_all.deb ;;
    -1)
    file=freeplane_$VERSION~upstream-1_all.deb ;;
esac 

PKGURL="https://download.sourceforge.net/project/freeplane/freeplane%20stable/${file}"

install_pkgurl
