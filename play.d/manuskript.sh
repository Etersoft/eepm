#!/bin/sh

PKGNAME=manuskript
SUPPORTEDARCHES=""
VERSION="$2"
RELEASE="$3"
DESCRIPTION="A open-source tool for writers for Linux from the official site"
URL="http://www.theologeek.ch/manuskript"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        file="${PKGNAME}-${VERSION}-${RELEASE}.noarch.rpm"
        ;;
    *)
        file="${PKGNAME}-${VERSION}-${RELEASE}.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "https://github.com/olivierkes/manuskript" "$file")"
else
    PKGURL="https://github.com/olivierkes/manuskript/releases/download/$VERSION/$file"
fi

install_pkgurl

